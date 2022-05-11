//
//  DownloadSessionTests.swift
//  VidLoaderTests
//
//  Created by Petre on 12/9/19.
//  Copyright © 2019 Petre. All rights reserved.
//

import XCTest
import AVFoundation
@testable import VidLoader

final class DownloadSessionTests: XCTestCase {
    private var session: DownloadSession!
    private var avDownloadSession: MockAVAssetDownloadURLSession!
    
    override func setUp() {
        super.setUp()
        
        session = DownloadSession()
        avDownloadSession = MockAVAssetDownloadURLSession.mock()
    }
    
    func test_GetAllTasks_SessionContainsActiveTasks_ResultContainsThem() {
        // GIVEN
        session.setup(injectedSession: avDownloadSession, stateChanged: nil)
        var resultTasks: [AVAssetDownloadTask]?
        let expectedTasks = [MockAVAssetDownloadTask.mock(), MockAVAssetDownloadTask.mock()]
        avDownloadSession.getAllTasksStub = expectedTasks
        
        // WHEN
        session.allTasks { tasks in
            resultTasks = tasks
        }
        
        // THEN
        XCTAssertEqual(expectedTasks, resultTasks)
    }
    
    func test_GetTask_SessionContainsActiveTask_ResultIsNotNil() {
        // GIVEN
        session.setup(injectedSession: avDownloadSession, stateChanged: nil)
        let givenIdentifier = "task_to_search"
        let expectedTask = MockAVAssetDownloadTask.mock()
        let givenItem = ItemInformation.mock(identifier: givenIdentifier)
        (expectedTask as URLSessionTask).save(item: givenItem)
        var resultTask: AVAssetDownloadTask?
        avDownloadSession.getAllTasksStub = [expectedTask]
        
        // WHEN
        session.task(identifier: givenIdentifier) { newTask in
            resultTask = newTask
        }
        
        // THEN
        XCTAssertEqual(expectedTask, resultTask)
    }
    
    func test_GetTask_SessionNotContainsTask_ResultIsNil() {
        // GIVEN
        session.setup(injectedSession: avDownloadSession, stateChanged: nil)
        let givenIdentifier = "task_to_search"
        var resultTask: AVAssetDownloadTask?
        avDownloadSession.getAllTasksStub = []
        
        // WHEN
        session.task(identifier: givenIdentifier) { newTask in
            resultTask = newTask
        }
        
        // THEN
        XCTAssertNil(resultTask)
    }
    
    func test_CreateNewTask_CreationSucceeded_NewTaskReturned() {
        // GIVEN
        let givenIdentifier = "new_task_identifier"
        let givenTitle = "new_task_title"
        let givenBitrate = 1213
        let givenArtwork = Data.mock(string: "mock_artwork")
        let expectedState: DownloadState = .keyLoaded
        let expectedItem = ItemInformation.mock(identifier: givenIdentifier, title: givenTitle,
                                                state: expectedState, artworkData: givenArtwork,
                                                minRequiredBitrate: givenBitrate)
        var resultState: DownloadState?
        var resultItem: ItemInformation?
        session.setup(injectedSession: avDownloadSession, stateChanged: { state, item in
            resultState = state
            resultItem = item
        })
        let expectedTask = MockAVAssetDownloadTask.mock()
        (expectedTask as URLSessionTask).save(item: expectedItem)
        avDownloadSession.makeAssetDownloadTaskStub = expectedTask
        
        // WHEN
        let resultTask = session.addNewTask(urlAsset: .mock(), for: expectedItem)
        
        // THEN
        XCTAssertTrue(avDownloadSession.makeAssetDownloadTaskFuncCheck.wasCalled(with: givenTitle))
        XCTAssertEqual(expectedTask, resultTask)
        XCTAssertEqual(expectedState, resultState)
        XCTAssertEqual(expectedItem, resultItem)
    }
    
    func test_CreateNewTask_CreationFailed_ReturnedTaskIsNil() {
        // GIVEN
        let givenIdentifier = "new_task_identifier"
        let expectedTitle = ""
        let expectedState: DownloadState = .failed(error: .taskNotCreated)
        let expectedItem = ItemInformation.mock(identifier: givenIdentifier, title: nil, state: .keyLoaded)
        var resultState: DownloadState?
        var resultItem: ItemInformation?
        session.setup(injectedSession: avDownloadSession, stateChanged: { state, item in
            resultState = state
            resultItem = item
        })
        avDownloadSession.makeAssetDownloadTaskStub = nil
        
        // WHEN
        let resultTask = session.addNewTask(urlAsset: .mock(), for: expectedItem)
        
        // THEN
        XCTAssertTrue(avDownloadSession.makeAssetDownloadTaskFuncCheck.wasCalled(with: expectedTitle))
        XCTAssertNil(resultTask)
        XCTAssertEqual(expectedState, resultState)
        XCTAssertEqual(expectedItem, resultItem)
    }
    
    func test_CancelTask_SessionNotContainsTask_HasNotFoundCalled() {
        // GIVEN
        session.setup(injectedSession: avDownloadSession, stateChanged: nil)
        let givenIdentifier = "cancel_task_identifier"
        var hasNotFound: Bool?
        
        // WHEN
        session.cancelTask(identifier: givenIdentifier, hasNotFound: { hasNotFound = true })
        
        // THEN
        XCTAssertEqual(hasNotFound, true)
    }
    
    func test_CancelTask_SessionContainsTask_TaskCanceled() {
        // GIVEN
        session.setup(injectedSession: avDownloadSession, stateChanged: nil)
        let givenIdentifier = "cancel_task_identifier"
        var hasNotFound: Bool?
        let givenTask = MockAVAssetDownloadTask.mock()
        givenTask.save(item: .mock(identifier: givenIdentifier))
        avDownloadSession.getAllTasksStub = [givenTask]
        
        // WHEN
        session.cancelTask(identifier: givenIdentifier, hasNotFound: { hasNotFound = true })
        
        // THEN
        XCTAssertNil(hasNotFound)
        XCTAssertTrue(givenTask.cancelFunc.wasCalled())
    }
    
    func test_SuspendAllTasks_SessionContainsTasks_AllTasksSuspended() {
        // GIVEN
        session.setup(injectedSession: avDownloadSession, stateChanged: nil)
        let firstTask = MockAVAssetDownloadTask.mock()
        let secondTask = MockAVAssetDownloadTask.mock()
        avDownloadSession.getAllTasksStub = [firstTask, secondTask]
        
        // WHEN
        session.suspendAllTasks()
        
        // THEN
        XCTAssertTrue(firstTask.suspendFunc.wasCalled())
        XCTAssertTrue(secondTask.suspendFunc.wasCalled())
    }
    
    func test_ResumeAllTasks_SessionContainsTasks_AllTasksResumed() {
        // GIVEN
        session.setup(injectedSession: avDownloadSession, stateChanged: nil)
        let firstTask = MockAVAssetDownloadTask.mock()
        let secondTask = MockAVAssetDownloadTask.mock()
        avDownloadSession.getAllTasksStub = [firstTask, secondTask]
        
        // WHEN
        session.resumeAllTasks()
        
        // THEN
        XCTAssertTrue(firstTask.resumeFunc.wasCalled())
        XCTAssertTrue(secondTask.resumeFunc.wasCalled())
    }
    
    func test_SendKeyLoadedEvent_SessionNotContainsTask_NoEventWillBeCalled() {
        // GIVEN
        var resultState: DownloadState?
        var resultItem: ItemInformation?
        session.setup(injectedSession: avDownloadSession, stateChanged: { state, item in
            resultState = state
            resultItem = item
        })
        avDownloadSession.getAllTasksStub = []
        
        // WHEN
        session.sendKeyLoaded(item: .mock())
        
        // THEN
        XCTAssertNil(resultState)
        XCTAssertNil(resultItem)
    }
    
    func test_SendKeyLoadedEvent_SessionContainsTask_EventCalled() {
        // GIVEN
        let givenItem: ItemInformation = .mock()
        let expectedState: DownloadState = .keyLoaded
        let expectedItem = givenItem |> ItemInformation._state .~ expectedState
        var resultState: DownloadState?
        var resultItem: ItemInformation?
        session.setup(injectedSession: avDownloadSession, stateChanged: { state, item in
            resultState = state
            resultItem = item
        })
        let givenTask = MockAVAssetDownloadTask.mock()
        givenTask.save(item: givenItem)
        avDownloadSession.getAllTasksStub = [givenTask]
        
        // WHEN
        session.sendKeyLoaded(item: expectedItem)
        
        // THEN
        XCTAssertEqual(expectedState, resultState)
        XCTAssertEqual(expectedItem, resultItem)
    }
    
    // MARK: - AVAssetDownloadDelegate Tests
    
    func test_FinishDownloading_NoItemInTask_NoStateUpdates() {
        // GIVEN
        var resultState: DownloadState?
        var resultItem: ItemInformation?
        session.setup(injectedSession: avDownloadSession, stateChanged: { state, item in
            resultState = state
            resultItem = item
        })
        let givenTask = MockAVAssetDownloadTask.mock()
        
        // WHEN
        session.urlSession(avDownloadSession, assetDownloadTask: givenTask, didFinishDownloadingTo: .mock())
        
        // THEN
        XCTAssertNil(resultState)
        XCTAssertNil(resultItem)
    }
    
    func test_FinishDownloading_TaskStateSuspended_StateChanged() {
        // GIVEN
        var resultState: DownloadState?
        var resultItem: ItemInformation?
        let givenIdentifier = "test_item_identifier"
        let givenItem: ItemInformation = ItemInformation.mock(identifier: givenIdentifier)
        let givenURL: URL = .mock(stringURL: "local_download_path")
        let expectedItem = givenItem |> ItemInformation._path .~ givenURL.absoluteString
        let expectedState: DownloadState = .noConnection(expectedItem.progress)
        session.setup(injectedSession: avDownloadSession, stateChanged: { state, item in
            resultState = state
            resultItem = item
        })
        let givenTask = MockAVAssetDownloadTask.mock()
        givenTask.stateStub = .suspended
        givenTask.save(item: givenItem)
        
        // WHEN
        session.urlSession(avDownloadSession, assetDownloadTask: givenTask, didFinishDownloadingTo: givenURL)
        
        // THEN
        XCTAssertEqual(expectedState, resultState)
        XCTAssertEqual(expectedItem, resultItem)
    }
    
    func test_FinishDownloading_TaskStateCanceled_StateChanged() {
        // GIVEN
        var resultState: DownloadState?
        var resultItem: ItemInformation?
        let givenIdentifier = "test_item_identifier"
        let givenItem: ItemInformation = ItemInformation.mock(identifier: givenIdentifier)
        let givenURL: URL = .mock(stringURL: "local_download_path")
        let expectedItem = givenItem |> ItemInformation._path .~ givenURL.absoluteString
        let expectedState: DownloadState = .canceled
        session.setup(injectedSession: avDownloadSession, stateChanged: { state, item in
            resultState = state
            resultItem = item
        })
        let givenTask = MockAVAssetDownloadTask.mock()
        givenTask.stateStub = .canceling
        givenTask.save(item: givenItem)
        
        // WHEN
        session.urlSession(avDownloadSession, assetDownloadTask: givenTask, didFinishDownloadingTo: givenURL)
        
        // THEN
        XCTAssertEqual(expectedState, resultState)
        XCTAssertEqual(expectedItem, resultItem)
    }
    
    func test_FinishDownloading_TaskStateCompleted_StateChanged() {
        // GIVEN
        var resultState: DownloadState?
        var resultItem: ItemInformation?
        let givenIdentifier = "test_item_identifier"
        let givenItem: ItemInformation = ItemInformation.mock(identifier: givenIdentifier)
        let givenURL: URL = .mock(stringURL: "local_download_path")
        let expectedItem = givenItem |> ItemInformation._path .~ givenURL.absoluteString
        let expectedState: DownloadState = .completed
        session.setup(injectedSession: avDownloadSession, stateChanged: { state, item in
            resultState = state
            resultItem = item
        })
        let givenTask = MockAVAssetDownloadTask.mock()
        givenTask.stateStub = .completed
        givenTask.save(item: givenItem)
        
        // WHEN
        session.urlSession(avDownloadSession, assetDownloadTask: givenTask, didFinishDownloadingTo: givenURL)
        
        // THEN
        XCTAssertEqual(expectedState, resultState)
        XCTAssertEqual(expectedItem, resultItem)
    }
    
    func test_FinishDownloading_TaskStateRunning_CompletedStateCalled() {
        // GIVEN
        var resultState: DownloadState?
        var resultItem: ItemInformation?
        let givenIdentifier = "test_item_identifier"
        let givenItem: ItemInformation = ItemInformation.mock(identifier: givenIdentifier)
        let givenURL: URL = .mock(stringURL: "local_download_path")
        let expectedItem = givenItem |> ItemInformation._path .~ givenURL.absoluteString
        let expectedState: DownloadState = .completed
        session.setup(injectedSession: avDownloadSession, stateChanged: { state, item in
            resultState = state
            resultItem = item
        })
        let givenTask = MockAVAssetDownloadTask.mock()
        givenTask.stateStub = .running
        givenTask.save(item: givenItem)
        
        // WHEN
        session.urlSession(avDownloadSession, assetDownloadTask: givenTask, didFinishDownloadingTo: givenURL)
        
        // THEN
        XCTAssertEqual(expectedState, resultState)
        XCTAssertEqual(expectedItem, resultItem)
    }
    
    func test_FinishDownloading_TaskStateRunningWithError_ErrorStateCalled() {
        // GIVEN
        var resultState: DownloadState?
        var resultItem: ItemInformation?
        let givenIdentifier = "test_item_identifier"
        let givenDownloadError: DownloadError = .unknown
        let expectedState: DownloadState = .failed(error: .custom(.init(error: givenDownloadError)))
        let givenItem: ItemInformation = ItemInformation.mock(identifier: givenIdentifier, state: expectedState)
        let givenURL: URL = .mock(stringURL: "local_download_path")
        let expectedItem = givenItem |> ItemInformation._path .~ givenURL.absoluteString
        session.setup(injectedSession: avDownloadSession, stateChanged: { state, item in
            resultState = state
            resultItem = item
        })
        let givenTask = MockAVAssetDownloadTask.mock()
        givenTask.stateStub = .running
        givenTask.error = givenDownloadError
        givenTask.save(item: givenItem)
        
        // WHEN
        session.urlSession(avDownloadSession, assetDownloadTask: givenTask, didFinishDownloadingTo: givenURL)
        
        // THEN
        XCTAssertEqual(expectedState, resultState)
        XCTAssertEqual(expectedItem, resultItem)
    }
    
    func test_FinishDownloading_TaskStateCompletedItemStateCanceled_CancelStateCalled() {
        // GIVEN
        var resultState: DownloadState?
        var resultItem: ItemInformation?
        let givenIdentifier = "test_item_identifier"
        let expectedState: DownloadState = .canceled
        let givenItem: ItemInformation = ItemInformation.mock(identifier: givenIdentifier, state: expectedState)
        let givenURL: URL = .mock(stringURL: "local_download_path")
        let expectedItem = givenItem |> ItemInformation._path .~ givenURL.absoluteString
        session.setup(injectedSession: avDownloadSession, stateChanged: { state, item in
            resultState = state
            resultItem = item
        })
        let givenTask = MockAVAssetDownloadTask.mock()
        givenTask.stateStub = .completed
        givenTask.save(item: givenItem)
        
        // WHEN
        session.urlSession(avDownloadSession, assetDownloadTask: givenTask, didFinishDownloadingTo: givenURL)
        
        // THEN
        XCTAssertEqual(expectedState, resultState)
        XCTAssertEqual(expectedItem, resultItem)
    }
    
    func test_SessionDidLoad_TaskStateNotRunning_NoStateUpdates() {
        // GIVEN
        var resultState: DownloadState?
        var resultItem: ItemInformation?
        let givenIdentifier = "test_item_identifier"
        let givenItem: ItemInformation = ItemInformation.mock(identifier: givenIdentifier, state: .running(0))
        session.setup(injectedSession: avDownloadSession, stateChanged: { state, item in
            resultState = state
            resultItem = item
        })
        let givenTask = MockAVAssetDownloadTask.mock()
        givenTask.stateStub = .completed
        givenTask.save(item: givenItem)
        
        // WHEN
        session.urlSession(avDownloadSession, assetDownloadTask: givenTask,
                           didLoad: .mock(), totalTimeRangesLoaded: [],
                           timeRangeExpectedToLoad: .mock())

        // THEN
        XCTAssertNil(resultState)
        XCTAssertNil(resultItem)
    }
    
    func test_SessionDidLoad_TaskItemNil_NoStateUpdates() {
        // GIVEN
        var resultState: DownloadState?
        var resultItem: ItemInformation?
        session.setup(injectedSession: avDownloadSession, stateChanged: { state, item in
            resultState = state
            resultItem = item
        })
        let givenTask = MockAVAssetDownloadTask.mock()
        givenTask.stateStub = .running
        
        // WHEN
        session.urlSession(avDownloadSession, assetDownloadTask: givenTask,
                           didLoad: .mock(), totalTimeRangesLoaded: [],
                           timeRangeExpectedToLoad: .mock())

        // THEN
        XCTAssertNil(resultState)
        XCTAssertNil(resultItem)
    }
    
    func test_SessionDidLoad_LoadInformationChanged_RunningCalled() {
        // GIVEN
        var resultState: DownloadState?
        var resultItem: ItemInformation?
        let expectedProgress = 0.5
        let expectedBytes = 2000
        let expectedState: DownloadState = .running(expectedProgress)
        let givenItem: ItemInformation = ItemInformation.mock(state: .unknown)
        let expectedItem = givenItem
            |> ItemInformation._progress .~ expectedProgress
            |> ItemInformation._downloadedBytes .~ expectedBytes
        session.setup(injectedSession: avDownloadSession, stateChanged: { state, item in
            resultState = state
            resultItem = item
        })
        let givenTask = MockAVAssetDownloadTask.mock()
        givenTask.stateStub = .running
        givenTask.countOfBytesReceivedStub = Int64(expectedBytes)
        givenTask.save(item: givenItem)
        
        // WHEN
        session.urlSession(avDownloadSession,
                           assetDownloadTask: givenTask,
                           didLoad: .mock(),
                           totalTimeRangesLoaded: [.mock(timeRange: .mock(start: .zero, duration: .mock(seconds: 10, scale: 1)))],
                           timeRangeExpectedToLoad: .mock(start: .zero, duration: .mock(seconds: 20, scale: 1)))
        
        // THEN
        XCTAssertEqual(expectedState, resultState)
        XCTAssertEqual(expectedItem, resultItem)
    }
    
    func test_CompleteWithError_NoItemInTask_NoStateUpdates() {
        // GIVEN
        var resultState: DownloadState?
        var resultItem: ItemInformation?
        let givenError: DownloadError = .unknown
        session.setup(injectedSession: avDownloadSession, stateChanged: { state, item in
            resultState = state
            resultItem = item
        })
        let givenTask = MockAVAssetDownloadTask.mock()
        givenTask.stateStub = .running
        
        // WHEN
        session.urlSession(avDownloadSession, task: givenTask, didCompleteWithError: givenError)

        // THEN
        XCTAssertNil(resultState)
        XCTAssertNil(resultItem)
    }
    
    func test_CompleteWithError_ItemStateCanceled_NoStateUpdates() {
        // GIVEN
        var resultState: DownloadState?
        var resultItem: ItemInformation?
        let givenError: DownloadError = .unknown
        session.setup(injectedSession: avDownloadSession, stateChanged: { state, item in
            resultState = state
            resultItem = item
        })
        let givenItem: ItemInformation = .mock(state: .canceled)
        let givenTask = MockAVAssetDownloadTask.mock()
        givenTask.stateStub = .completed
        givenTask.save(item: givenItem)
        
        // WHEN
        session.urlSession(avDownloadSession, task: givenTask, didCompleteWithError: givenError)

        // THEN
        XCTAssertNil(resultState)
        XCTAssertNil(resultItem)
    }
    
    func test_CompleteWithError_ErrorIsNil_NoStateUpdates() {
        // GIVEN
        var resultState: DownloadState?
        var resultItem: ItemInformation?
        session.setup(injectedSession: avDownloadSession, stateChanged: { state, item in
            resultState = state
            resultItem = item
        })
        let givenItem: ItemInformation = .mock(state: .running(0))
        let givenTask = MockAVAssetDownloadTask.mock()
        givenTask.stateStub = .completed
        givenTask.save(item: givenItem)
        
        // WHEN
        session.urlSession(avDownloadSession, task: givenTask, didCompleteWithError: nil)

        // THEN
        XCTAssertNil(resultState)
        XCTAssertNil(resultItem)
    }
    
    func test_CompleteWithError_TaskAlreadyFailed_NoStateUpdates() {
        // GIVEN
        var resultState: DownloadState?
        var resultItem: ItemInformation?
        let givenError: DownloadError = .unknown
        session.setup(injectedSession: avDownloadSession, stateChanged: { state, item in
            resultState = state
            resultItem = item
        })
        let givenItem: ItemInformation = .mock(state: .failed(error: .unknown))
        let givenTask = MockAVAssetDownloadTask.mock()
        givenTask.stateStub = .running
        givenTask.save(item: givenItem)
        
        // WHEN
        session.urlSession(avDownloadSession, task: givenTask, didCompleteWithError: givenError)

        // THEN
        XCTAssertNil(resultState)
        XCTAssertNil(resultItem)
    }
    
    func test_CompleteWithError_ErrorExist_FailedStateCalled() {
        // GIVEN
        var resultState: DownloadState?
        var resultItem: ItemInformation?
        let givenError: DownloadError = .unknown
        let expectedState: DownloadState = .failed(error: .custom(.init(error: givenError)))
        let givenItem: ItemInformation = .mock()
        let expectedItem = givenItem |> ItemInformation._state .~ expectedState
        session.setup(injectedSession: avDownloadSession, stateChanged: { state, item in
            resultState = state
            resultItem = item
        })
        
        let givenTask = MockAVAssetDownloadTask.mock()
        givenTask.stateStub = .running
        givenTask.save(item: givenItem)
        
        // WHEN
        session.urlSession(avDownloadSession, task: givenTask, didCompleteWithError: givenError)

        // THEN
        XCTAssertEqual(expectedState, resultState)
        XCTAssertEqual(expectedItem, resultItem)
    }

    func test_SessionContainsTask_PauseWasCalled_TaskWasPassed() {
        // GIVEN
        let stateChangeFunc = FuncCheck<(DownloadState, ItemInformation)>()
        session.setup(injectedSession: avDownloadSession,
                      stateChanged: { stateChangeFunc.call(($0, $1)) })
        let givenIdentifier = "suspend_task"
        let givenItem = ItemInformation.mock(identifier: givenIdentifier, progress: 23)
        let expectedState = DownloadState.paused(givenItem.progress)
        let expectedItem = givenItem |> ItemInformation._state .~ expectedState
        let givenTask = MockAVAssetDownloadTask.mock()
        givenTask.save(item: givenItem)
        avDownloadSession.getAllTasksStub = [givenTask]
        
        // WHEN
        session.suspendTask(identifier: givenIdentifier)
        
        // THEN
        XCTAssertEqual(stateChangeFunc.arguments?.0, expectedState)
        XCTAssertEqual(stateChangeFunc.arguments?.1, expectedItem)
        XCTAssertEqual(givenTask.item, expectedItem)
        XCTAssertTrue(givenTask.suspendFunc.wasCalled())
    }
    
    func test_SessionNotContainsTask_PauseWasCalled_StateNotChanged() {
        // GIVEN
        let stateChangeFunc = FuncCheck<(DownloadState, ItemInformation)>()
        session.setup(injectedSession: avDownloadSession,
                      stateChanged: { stateChangeFunc.call(($0, $1)) })
        let givenIdentifier = "suspend_task"
        
        // WHEN
        session.suspendTask(identifier: givenIdentifier)
        
        // THEN
        XCTAssertNil(stateChangeFunc.arguments?.0)
        XCTAssertNil(stateChangeFunc.arguments?.1)
    }
    
    func test_SessionContainsTask_ResumeWasCalled_TaskWasResumed() {
        // GIVEN
        let stateChangeFunc = FuncCheck<(DownloadState, ItemInformation)>()
        session.setup(injectedSession: avDownloadSession,
                      stateChanged: { stateChangeFunc.call(($0, $1)) })
        let givenIdentifier = "resume_task"
        let givenItem = ItemInformation.mock(identifier: givenIdentifier, progress: 23)
        let expectedState = DownloadState.waiting
        let expectedItem = givenItem |> ItemInformation._state .~ expectedState
        let givenTask = MockAVAssetDownloadTask.mock()
        givenTask.save(item: givenItem)
        avDownloadSession.getAllTasksStub = [givenTask]
        
        // WHEN
        session.resumeTask(identifier: givenIdentifier)
        
        // THEN
        XCTAssertEqual(stateChangeFunc.arguments?.0, expectedState)
        XCTAssertEqual(stateChangeFunc.arguments?.1, expectedItem)
        XCTAssertEqual(givenTask.item, expectedItem)
        XCTAssertTrue(givenTask.resumeFunc.wasCalled())
    }
    
    func test_SessionNotContainsTask_ResumeWasCalled_StateNotChanged() {
        // GIVEN
        let stateChangeFunc = FuncCheck<(DownloadState, ItemInformation)>()
        session.setup(injectedSession: avDownloadSession,
                      stateChanged: { stateChangeFunc.call(($0, $1)) })
        let givenIdentifier = "resume_task"
        
        // WHEN
        session.resumeTask(identifier: givenIdentifier)
        
        // THEN
        XCTAssertNil(stateChangeFunc.arguments?.0)
        XCTAssertNil(stateChangeFunc.arguments?.1)
    }
    
    func test_TaskWasPaused_SuspendAllTasks_SuspendNotCalled() {
        // GIVEN
        session.setup(injectedSession: avDownloadSession, stateChanged: nil)
        let task = MockAVAssetDownloadTask.mock()
        task.save(item: .mock(state: .paused(10)))
        avDownloadSession.getAllTasksStub = [task]
        
        // WHEN
        session.suspendAllTasks()
        
        // THEN
        XCTAssertFalse(task.suspendFunc.wasCalled())
    }

    func test_TaskWasPaused_ResumeAllTasks_ResumeNotCalled() {
        // GIVEN
        session.setup(injectedSession: avDownloadSession, stateChanged: nil)
        let task = MockAVAssetDownloadTask.mock()
        task.save(item: .mock(state: .paused(10)))
        avDownloadSession.getAllTasksStub = [task]
        
        // WHEN
        session.resumeAllTasks()
        
        // THEN
        XCTAssertFalse(task.resumeFunc.wasCalled())
    }
}
