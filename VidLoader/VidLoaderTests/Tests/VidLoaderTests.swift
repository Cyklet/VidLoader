//
//  VidLoaderTests.swift
//  VidLoaderTests
//
//  Created by Petre on 12/11/19.
//  Copyright © 2019 Petre. All rights reserved.
//

import XCTest
@testable import VidLoader

final class VidLoaderTests: XCTestCase {
    private var vidLoader: VidLoader!
    private var session: MockSession!
    private var playlistLoader: MockPlaylistLoadable!
    private var network: MockNetwork!
    private var schemeHandler: MockSchemeHandler!
    private var resourcesDelegatesHandler: MockResourcesDelegatesHandleable!
    private var fileHandler: MockFileHandleable!
    private var keyLoader: MockKeyLoadable!
    private var observersHandler: MockObserversHandleable!
    
    override func setUp() {
        super.setUp()
        
        session = MockSession()
        playlistLoader = MockPlaylistLoadable()
        network = MockNetwork()
        resourcesDelegatesHandler = MockResourcesDelegatesHandleable()
        fileHandler = MockFileHandleable()
        keyLoader = MockKeyLoadable()
        schemeHandler = MockSchemeHandler()
        observersHandler = MockObserversHandleable()
    }
    
    private func createVidLoader(isMobileDataAccessEnabled: Bool = true,
                                 maxConcurrentDownloads: Int = 3) -> VidLoader {
        return VidLoader(isMobileDataAccessEnabled: isMobileDataAccessEnabled,
                         maxConcurrentDownloads: maxConcurrentDownloads,
                         session: session,
                         playlistLoader: playlistLoader,
                         network: network,
                         schemeHandler: schemeHandler,
                         resourcesDelegatesHandler: resourcesDelegatesHandler,
                         fileHandler: fileHandler,
                         keyLoader: keyLoader,
                         observersHandler: observersHandler)
    }
    
    func test_CreateVidLoader_NoTasksInSession_ObserversNotCalled() {
        // GIVEN
        
        // WHEN
        vidLoader = createVidLoader(isMobileDataAccessEnabled: true)
        session.setupStub?(.unknown, .mock())
        network.setupStub?(.available)
        
        // THEN
        XCTAssertTrue(network.setupFuncCheck.wasCalled())
        XCTAssertTrue(network.enableMobileDataAccessFuncCheck.wasCalled())
        XCTAssertEqual(observersHandler.fireFuncCheck.count, 0)
        XCTAssertTrue(session.allTasksFuncCheck.wasCalled())
        XCTAssertTrue(session.setupFuncCheck.wasCalled(with: nil))
        XCTAssertTrue(session.resumeAllTasksFuncCheck.wasCalled())
    }
    
    func test_CreateVidLoader_TasksInSession_ObserversAreCalled() {
        // GIVEN
        let givenState: DownloadState = .completed
        let givenIdentifier = "unique_identifier"
        let givenItem: ItemInformation = .mock(identifier: givenIdentifier)
        let task = MockAVAssetDownloadTask.mock()
        task.save(item: givenItem)
        session.allTasksStub = [task, task, MockAVAssetDownloadTask.mock()]
        let expectedItem = givenItem |> ItemInformation._state .~ givenState
        
        // WHEN
        vidLoader = createVidLoader(isMobileDataAccessEnabled: false)
        session.setupStub?(givenState, givenItem)
        network.setupStub?(.unavailable)
        
        // THEN
        XCTAssertTrue(network.disableMobileDataAccessFuncCheck.wasCalled())
        XCTAssertTrue(network.setupFuncCheck.wasCalled())
        XCTAssertEqual(observersHandler.fireFuncCheck.count, 2)
        XCTAssertEqual(observersHandler.fireFuncCheck.arguments?.0, ObserverType.single(givenIdentifier))
        XCTAssertEqual(observersHandler.fireFuncCheck.arguments?.1, expectedItem)
        XCTAssertTrue(session.allTasksFuncCheck.wasCalled())
        XCTAssertTrue(session.setupFuncCheck.wasCalled(with: nil))
        XCTAssertTrue(session.suspendAllTasksFuncCheck.wasCalled())
    }
    
    func test_AddObserver_ObserverIsNewOne_ItWasAdded() {
        // GIVEN
        vidLoader = createVidLoader()
        let givenObserver = VidObserver(type: .all, stateChanged: { _ in })
        
        // WHEN
        vidLoader.observe(with: givenObserver)
        
        // THEN
        XCTAssertTrue(observersHandler.addFuncCheck.wasCalled(with: givenObserver))
    }
    
    func test_RemoveObserver_ObserverExist_ItWasRemoved() {
        // GIVEN
        vidLoader = createVidLoader()
        let givenObserver = VidObserver(type: .single("random_identifier"), stateChanged: { _ in })
        
        // WHEN
        vidLoader.remove(observer: givenObserver)
        
        // THEN
        XCTAssertTrue(observersHandler.removeFuncCheck.wasCalled(with: givenObserver))
    }
    
    func test_DownloadItem_AlreadyExist_DownloadIsIgnored() {
        // GIVEN
        let givenIdentifier = "persitent_identifier"
        let givenItem = ItemInformation.mock(identifier: givenIdentifier)
        let task = MockAVAssetDownloadTask.mock()
        task.save(item: givenItem)
        session.allTasksStub = [task]
        vidLoader = createVidLoader()
        
        // WHEN
        vidLoader.download(.mock(identifier: givenIdentifier))
        
        // THEN
        XCTAssertEqual(session.taskFuncCheck.count, 0)
    }
    
    func test_DownloadItem_ItemIsNewAndNoActiveTaskForIt_DownloadWillStart() {
        // GIVEN
        let givenIdentifier = "persistent_identifier"
        let givenURL: URL = .mock(stringURL: "persistent_URL")
        let givenTitle = "persistent_title"
        let givenData: Data = .mock()
        let givenBitrate: Int = 12312
        session.allTasksStub = []
        vidLoader = createVidLoader()
        playlistLoader.loadStub = .success(())
        let expectedItem = ItemInformation.mock(identifier: givenIdentifier,
                                                title: givenTitle.removingIllegalCharacters,
                                                mediaLink: givenURL.absoluteString,
                                                state: .waiting,
                                                artworkData: givenData,
                                                minRequiredBitrate: givenBitrate)
        
        // WHEN
        vidLoader.download(.mock(identifier: givenIdentifier, url: givenURL,
                                 title: givenTitle, artworkData: givenData,
                                 minRequiredBitrate: givenBitrate))
        
        // THEN
        XCTAssertTrue(session.taskFuncCheck.wasCalled(with: givenIdentifier))
        XCTAssertEqual(observersHandler.fireFuncCheck.count, 4)
        XCTAssertEqual(observersHandler.fireFuncCheck.arguments?.0, ObserverType.single(givenIdentifier))
        XCTAssertEqual(observersHandler.fireFuncCheck.arguments?.1, expectedItem)
        XCTAssertEqual(playlistLoader.loadFuncCheck.arguments?.0, givenIdentifier)
        XCTAssertEqual(playlistLoader.loadFuncCheck.arguments?.1, givenURL)
    }
    
    func test_DownloadItem_ItemIsNewButActiveTaskForItExist_DownloadWillNotStart() {
        // GIVEN
        let givenIdentifier = "persistent_identifier"
        let givenURL: URL = .mock(stringURL: "persistent_URL")
        let givenTitle = "persistent_title"
        let givenData: Data = .mock()
        let expectedItem = ItemInformation.mock(identifier: givenIdentifier,
                                                title: givenTitle.removingIllegalCharacters,
                                                mediaLink: givenURL.absoluteString,
                                                state: .prefetching,
                                                artworkData: givenData)
        session.allTasksStub = []
        let task = MockAVAssetDownloadTask.mock()
        task.save(item: expectedItem)
        session.taskStub = task
        vidLoader = createVidLoader()
        
        // WHEN
        vidLoader.download(.mock(identifier: givenIdentifier, url: givenURL, title: givenTitle, artworkData: givenData))
        
        // THEN
        XCTAssertTrue(session.taskFuncCheck.wasCalled(with: givenIdentifier))
        XCTAssertEqual(observersHandler.fireFuncCheck.count, 2)
        XCTAssertEqual(observersHandler.fireFuncCheck.arguments?.0, ObserverType.single(givenIdentifier))
        XCTAssertEqual(observersHandler.fireFuncCheck.arguments?.1, expectedItem)
        XCTAssertEqual(playlistLoader.loadFuncCheck.count, 0)
    }
    
    func test_DownloadItem_ItemIsNewButPlaylistRequestWillFail_DownloadWillNotStart() {
        // GIVEN
        let givenIdentifier = "persistent_identifier"
        let givenURL: URL = .mock(stringURL: "persistent_URL")
        let givenTitle = "persistent_title"
        let givenData: Data = .mock()
        session.allTasksStub = []
        vidLoader = createVidLoader()
        let expectedError: DownloadError = .unknown
        playlistLoader.loadStub = .failure(expectedError)
        let expectedItem = ItemInformation.mock(identifier: givenIdentifier,
                                                title: givenTitle.removingIllegalCharacters,
                                                mediaLink: givenURL.absoluteString,
                                                state: .failed(error: .custom(.init(error: expectedError))),
                                                artworkData: givenData)
        
        // WHEN
        vidLoader.download(.mock(identifier: givenIdentifier, url: givenURL, title: givenTitle, artworkData: givenData))
        
        // THEN
        XCTAssertTrue(session.taskFuncCheck.wasCalled(with: givenIdentifier))
        XCTAssertEqual(observersHandler.fireFuncCheck.count, 4)
        XCTAssertEqual(observersHandler.fireFuncCheck.arguments?.0, ObserverType.single(givenIdentifier))
        XCTAssertEqual(observersHandler.fireFuncCheck.arguments?.1, expectedItem)
        XCTAssertEqual(playlistLoader.loadFuncCheck.arguments?.0, givenIdentifier)
        XCTAssertEqual(playlistLoader.loadFuncCheck.arguments?.1, givenURL)
    }
    
    func test_CancelDownload_ActiveTaskNotFound_CancelEventWillFire() {
        // GIVEN
        let givenIdentifier = "random_given_identifier"
        let givenItem: ItemInformation = .mock(identifier: givenIdentifier)
        let expectedItem = givenItem |> ItemInformation._state .~ .canceled
        let task = MockAVAssetDownloadTask.mock()
        task.save(item: givenItem)
        session.allTasksStub = [task]
        vidLoader = createVidLoader()
        session.cancelTaskStub = true
        
        // WHEN
        vidLoader.cancel(identifier: givenIdentifier)
        
        // THEN
        XCTAssertTrue(playlistLoader.cancelFuncCheck.wasCalled(with: givenIdentifier))
        XCTAssertTrue(session.cancelTaskFuncCheck.wasCalled(with: givenIdentifier))
        XCTAssertEqual(observersHandler.fireFuncCheck.count, 2)
        XCTAssertEqual(observersHandler.fireFuncCheck.arguments?.0, ObserverType.single(givenIdentifier))
        XCTAssertEqual(observersHandler.fireFuncCheck.arguments?.1, expectedItem)
    }
    
    func test_CancelDownload_ActiveTaskFound_CancelEventWillNotFire() {
        // GIVEN
        let givenIdentifier = "random_given_identifier"
        let givenItem: ItemInformation = .mock(identifier: givenIdentifier)
        let task = MockAVAssetDownloadTask.mock()
        task.save(item: givenItem)
        session.allTasksStub = [task]
        vidLoader = createVidLoader()
        session.cancelTaskStub = false
        
        // WHEN
        vidLoader.cancel(identifier: givenIdentifier)
        
        // THEN
        XCTAssertTrue(playlistLoader.cancelFuncCheck.wasCalled(with: givenIdentifier))
        XCTAssertTrue(session.cancelTaskFuncCheck.wasCalled(with: givenIdentifier))
        XCTAssertEqual(observersHandler.fireFuncCheck.count, 0)
    }
    
    func test_CheckItemState_DownloaderDoNotHasItem_ReturnedStateIsUnknown() {
        // GIVEN
        let givenIdentifier = "identifier_to_search"
        vidLoader = createVidLoader()
        let expectedState: DownloadState = .unknown
        
        // WHEN
        let resultState = vidLoader.state(for: givenIdentifier)
        
        // THEN
        XCTAssertEqual(expectedState, resultState)
    }
    
    func test_CheckItemState_DownloaderHasItem_ItemStateWillReturn() {
        // GIVEN
        let givenIdentifier = "identifier_to_search"
        let expectedState: DownloadState = .keyLoaded
        let givenItem: ItemInformation = .mock(identifier: givenIdentifier, state: expectedState)
        let task = MockAVAssetDownloadTask.mock()
        task.save(item: givenItem)
        session.allTasksStub = [task]
        vidLoader = createVidLoader()
        
        // WHEN
        let resultState = vidLoader.state(for: givenIdentifier)
        
        // THEN
        XCTAssertEqual(expectedState, resultState)
    }
    
    func test_GenerateURLAsset_KeyloaderIsAvailable_AssetWillBeCreated() {
        // GIVEN
        vidLoader = createVidLoader()
        let givenURL: URL = .mock(stringURL: "random_given_url")
        
        // WHEN
        let urlAsset = vidLoader.asset(location: givenURL)
        
        // THEN
        XCTAssertEqual(givenURL, urlAsset?.url)
        XCTAssertEqual(urlAsset?.resourceLoader.preloadsEligibleContentKeys, true)
        XCTAssertTrue(keyLoader.queueFuncCheck.wasCalled())
    }
    
    func test_CancelActiveItems_ActiveItemsAreAvailable_DownloadsWillCancel() {
        // GIVEN
        let givenIdentifier = "identifier_to_cancel"
        let givenItem: ItemInformation = .mock(identifier: givenIdentifier)
        let task = MockAVAssetDownloadTask.mock()
        task.save(item: givenItem)
        session.allTasksStub = [task]
        vidLoader = createVidLoader()
        
        // WHEN
        vidLoader.cancelActiveItems()
        
        // THEN
        XCTAssertTrue(playlistLoader.cancelFuncCheck.wasCalled(with: givenIdentifier))
        XCTAssertTrue(session.cancelTaskFuncCheck.wasCalled(with: givenIdentifier))
    }
    
    func test_EnableMobileData_NetworkIsAvailable_MobileDataWillBeEnabled() {
        // GIVEN
        vidLoader = createVidLoader()
        
        // WHEN
        vidLoader.enableMobileDataAccess()
        
        // THEN
        XCTAssertTrue(network.enableMobileDataAccessFuncCheck.wasCalled())
    }
    
    func test_DisableMobileData_NetworkIsAvailable_MobileDataWillBeDisabled() {
        // GIVEN
        vidLoader = createVidLoader()
        
        // WHEN
        vidLoader.disableMobileDataAccess()
        
        // THEN
        XCTAssertTrue(network.disableMobileDataAccessFuncCheck.wasCalled())
    }
    
    func test_NetworkChanges_AllDownloadsPaused_SessionWillPauseDownloads() {
        // GIVEN
        vidLoader = createVidLoader()
        
        // WHEN
        network.setupStub?(.unavailable)
    
        // THEN
        XCTAssertTrue(session.suspendAllTasksFuncCheck.wasCalled())
    }

    func test_StartNextDownload_URLAssetCreationFailed_FailEventWillFire() {
        // GIVEN
        let givenURL: URL = .mock(stringURL: "url_to_download_from")
        let givenIdentifier = "item_to_download"
        let givenItem: ItemInformation = .mock(identifier: givenIdentifier, mediaLink: givenURL.absoluteString, state: .waiting)
        let givenTask = MockAVAssetDownloadTask.mock()
        givenTask.save(item: givenItem)
        session.allTasksStub = [givenTask]
        let expectedError: ResourceLoadingError = .unknown
        let expectedItem = givenItem |> ItemInformation._state .~ .failed(error: .custom(.init(error: expectedError)))
        schemeHandler.urlAssetStub = .failure(expectedError)
        vidLoader = createVidLoader()
        playlistLoader.nextStreamResource = (givenIdentifier, StreamResource(response: .mock(), data: .mock()))

        observersHandler.fireFuncCheck.reset()
        
        // WHEN
        session.setupStub?(.keyLoaded, givenItem)
        
        // THEN
        XCTAssertEqual(givenURL, schemeHandler.urlAssetFuncCheck.arguments?.0)
        XCTAssertEqual(observersHandler.fireFuncCheck.count, 4)
        XCTAssertEqual(observersHandler.fireFuncCheck.arguments?.0, ObserverType.single(givenIdentifier))
        XCTAssertEqual(observersHandler.fireFuncCheck.arguments?.1, expectedItem)
    }
    
    func test_StartNextDownload_URLAssetCreationSuccededButTaskCreationFailed_FailEventWillFire() {
        // GIVEN
        let givenURL: URL = .mock(stringURL: "url_to_download_from")
        let givenIdentifier = "item_to_download"
        let givenItem: ItemInformation = .mock(identifier: givenIdentifier, mediaLink: givenURL.absoluteString, state: .waiting)
        let givenTask = MockAVAssetDownloadTask.mock()
        givenTask.save(item: givenItem)
        let expectedItem = givenItem |> ItemInformation._state .~ .keyLoaded
        schemeHandler.urlAssetStub = .success(.mock())
        session.allTasksStub = [givenTask]
        vidLoader = createVidLoader()
        playlistLoader.nextStreamResource = (givenIdentifier, StreamResource(response: .mock(), data: .mock()))
        session.addNewTaskStub = nil
        observersHandler.fireFuncCheck.reset()
        
        // WHEN
        session.setupStub?(.keyLoaded, givenItem)
        
        // THEN
        XCTAssertEqual(givenURL, schemeHandler.urlAssetFuncCheck.arguments?.0)
        XCTAssertEqual(observersHandler.fireFuncCheck.count, 2)
        XCTAssertEqual(observersHandler.fireFuncCheck.arguments?.0, ObserverType.single(givenIdentifier))
        XCTAssertEqual(observersHandler.fireFuncCheck.arguments?.1, expectedItem)
    }
    
    func test_StartNextDownload_ResourceDelegateSetted_TaskResumeWillCall() {
        // GIVEN
        let givenURL: URL = .mock(stringURL: "url_to_download_from")
        let givenIdentifier = "item_to_download"
        let givenItem: ItemInformation = .mock(identifier: givenIdentifier, mediaLink: givenURL.absoluteString, state: .waiting)
        let givenTask = MockAVAssetDownloadTask.mock()
        givenTask.save(item: givenItem)
        let expectedItem = givenItem |> ItemInformation._state .~ .keyLoaded
        schemeHandler.urlAssetStub = .success(.mock())
        session.allTasksStub = [givenTask]
        vidLoader = createVidLoader()
        playlistLoader.nextStreamResource = (givenIdentifier, StreamResource(response: .mock(), data: .mock()))
        session.addNewTaskStub = givenTask
        observersHandler.fireFuncCheck.reset()
        
        // WHEN
        session.setupStub?(.keyLoaded, givenItem)
        
        // THEN
        XCTAssertEqual(givenURL, schemeHandler.urlAssetFuncCheck.arguments?.0)
        XCTAssertEqual(observersHandler.fireFuncCheck.count, 2)
        XCTAssertEqual(observersHandler.fireFuncCheck.arguments?.0, ObserverType.single(givenIdentifier))
        XCTAssertEqual(observersHandler.fireFuncCheck.arguments?.1, expectedItem)
        XCTAssertTrue(givenTask.resumeFunc.wasCalled())
        XCTAssertEqual(resourcesDelegatesHandler.addFuncCheck.arguments?.0, givenIdentifier)
        XCTAssertEqual(session.addNewTaskFuncCheck.arguments?.1, givenItem |> ItemInformation._state .~ .running(0))
    }

    func test_SessionWasSet_PausedWasCalled_SessionWillPauseTask() {
        // GIVEN
        let givenIdentifer = "pause_item"
        vidLoader = createVidLoader()
        
        // WHEN
        vidLoader.pause(identifier: givenIdentifer)
    
        // THEN
        XCTAssertTrue(session.suspendTaskFuncCheck.wasCalled(with: givenIdentifer))
    }

    func test_SessionWasSet_ResumeWasCalled_SessionWillResumeTask() {
        // GIVEN
        let givenIdentifer = "resume_item"
        vidLoader = createVidLoader()
        
        // WHEN
        vidLoader.resume(identifier: givenIdentifer)
    
        // THEN
        XCTAssertTrue(session.resumeTaskFuncCheck.wasCalled(with: givenIdentifer))
    }
}
