//
//  ResourceLoaderTests.swift
//  VidLoaderTests
//
//  Created by Petre on 12/9/19.
//  Copyright © 2019 Petre. All rights reserved.
//

import XCTest
import AVFoundation
@testable import VidLoader

final class ResourceLoaderTests: XCTestCase {
    private var resourceLoaderObserver: ResourceLoaderObserver!
    private var masterParser: MockMasterParser!
    private var playlistParser: MockPlaylistParser!
    private var requestable: MockRequestable!
    private var schemeHandler: MockSchemeHandler!
    private var resourceLoader: ResourceLoader!
    
    override func setUp() {
        super.setUp()
        
        masterParser = MockMasterParser()
        playlistParser = MockPlaylistParser()
        requestable = MockRequestable()
        schemeHandler = MockSchemeHandler()
    }
    
    private func setupResourceLoader(streamResource: StreamResource = .mock(),
                                     taskDidFail: @escaping Completion<ResourceLoadingError> = { _ in },
                                     keyDidLoad: @escaping () -> Void = { }) {
        resourceLoaderObserver = ResourceLoaderObserver(taskDidFail: taskDidFail,
                                                        keyDidLoad: keyDidLoad)
        resourceLoader = ResourceLoader(observer: resourceLoaderObserver,
                                        streamResource: streamResource,
                                        masterParser: masterParser,
                                        playlistParser: playlistParser,
                                        requestable: requestable,
                                        schemeHandler: schemeHandler)
    }
    
    func test_UnchangedHttpsURL_StartResourceLoader_SetupWasNotCalled() {
        // GIVEN
        setupResourceLoader()
        schemeHandler.schemeTypeStub = .original
        let url = URL.mock()
        let avResourceLoader = AVAssetResourceLoader.mock(url: url)
        let requestInfo = AVAssetResourceLoadingRequest.mockRequestInfo(infoURL: url)
        let loadingRequest = AVAssetResourceLoadingRequest.mockWithCustomSetup(with: avResourceLoader, requestInfo: requestInfo)
        
        // WHEN
        let requestShouldWait = resourceLoader.resourceLoader(avResourceLoader,
                                                              shouldWaitForLoadingOfRequestedResource: loadingRequest)
        
        // THEN
        XCTAssertFalse(requestShouldWait)
        XCTAssertNil(loadingRequest.setupFuncDidCall)
    }
    
    func test_UnknwonScheme_StartResourceLoader_SetupWasNotCalled() {
        // GIVEN
        setupResourceLoader()
        schemeHandler.schemeTypeStub = nil
        let url = URL.mock()
        let avResourceLoader = AVAssetResourceLoader.mock(url: url)
        let requestInfo = AVAssetResourceLoadingRequest.mockRequestInfo(infoURL: url)
        let loadingRequest = AVAssetResourceLoadingRequest.mockWithCustomSetup(with: avResourceLoader, requestInfo: requestInfo)
        
        // WHEN
        let requestShouldWait = resourceLoader.resourceLoader(avResourceLoader,
                                                              shouldWaitForLoadingOfRequestedResource: loadingRequest)
        
        // THEN
        XCTAssertFalse(requestShouldWait)
        XCTAssertNil(loadingRequest.setupFuncDidCall)
    }
    
    func test_CheckKeyResource_KeyExist_ResourceSetupWasCalled() {
        // GIVEN
        let keyFuncCheck = EmptyFuncCheck()
        setupResourceLoader(keyDidLoad: { keyFuncCheck.call() })
        schemeHandler.persistentKeyStub = Data.mock(string: "random_data")
        schemeHandler.schemeTypeStub = .key
        let url = URL.mock()
        let avResourceLoader = AVAssetResourceLoader.mock(url: url)
        let requestInfo = AVAssetResourceLoadingRequest.mockRequestInfo(infoURL: url)
        let loadingRequest = AVAssetResourceLoadingRequest.mockWithCustomSetup(with: avResourceLoader, requestInfo: requestInfo)
        
        // WHEN
        let requestShouldWait = resourceLoader.resourceLoader(avResourceLoader,
                                                              shouldWaitForLoadingOfRequestedResource: loadingRequest)
        
        // THEN
        XCTAssertTrue(requestShouldWait)
        XCTAssertEqual(loadingRequest.setupFuncDidCall, true)
        XCTAssertTrue(keyFuncCheck.wasCalled())
    }
    
    func test_CheckKeyResource_KeyIsNil_ResourceSetupWasNotCalled() {
        // GIVEN
        setupResourceLoader()
        schemeHandler.persistentKeyStub = nil
        schemeHandler.schemeTypeStub = .key
        let url = URL.mock()
        let avResourceLoader = AVAssetResourceLoader.mock(url: url)
        let requestInfo = AVAssetResourceLoadingRequest.mockRequestInfo(infoURL: url)
        let loadingRequest = AVAssetResourceLoadingRequest.mockWithCustomSetup(with: avResourceLoader, requestInfo: requestInfo)
        
        // WHEN
        let requestShouldWait = resourceLoader.resourceLoader(avResourceLoader,
                                                              shouldWaitForLoadingOfRequestedResource: loadingRequest)
        
        // THEN
        XCTAssertFalse(requestShouldWait)
        XCTAssertNil(loadingRequest.setupFuncDidCall)
    }
    
    func test_CheckMasterResource_ResourceHasWrongData_TaskDidFail() {
        // GIVEN
        let expectedParserError: M3U8Error = .dataConversion
        let expectedError: ResourceLoadingError = .m3u8(expectedParserError)
        let resultErrorFuncCheck = FuncCheck<ResourceLoadingError>()
        let keyFuncCheck = EmptyFuncCheck()
        let expectedData = Data.mock(string: "expected_data")
        masterParser.adjustStub = .failure(expectedParserError)
        setupResourceLoader(streamResource: StreamResource.mock(data: expectedData),
                            taskDidFail: { resultErrorFuncCheck.call($0) },
                            keyDidLoad: { keyFuncCheck.call() })
        schemeHandler.schemeTypeStub = .master
        let url = URL.mock()
        let avResourceLoader = AVAssetResourceLoader.mock(url: url)
        let requestInfo = AVAssetResourceLoadingRequest.mockRequestInfo(infoURL: url)
        let loadingRequest = AVAssetResourceLoadingRequest.mockWithCustomSetup(with: avResourceLoader, requestInfo: requestInfo)
        
        // WHEN
        let requestShouldWait = resourceLoader.resourceLoader(avResourceLoader,
                                                              shouldWaitForLoadingOfRequestedResource: loadingRequest)
        
        // THEN
        XCTAssertTrue(requestShouldWait)
        XCTAssertNil(loadingRequest.setupFuncDidCall)
        XCTAssertTrue(resultErrorFuncCheck.wasCalled(with: expectedError))
        XCTAssertFalse(keyFuncCheck.wasCalled())
        XCTAssertEqual(masterParser.adjustFuncCheck.arguments?.0, expectedData)
    }
    
    func test_CheckMasterResource_ResourceHasValidData_ResourceSetupWasCalled() {
        // GIVEN
        let resultErrorFuncCheck = FuncCheck<ResourceLoadingError>()
        let keyFuncCheck = EmptyFuncCheck()
        let expectedData = Data.mock(string: "expected_data")
        masterParser.adjustStub = .success(expectedData)
        setupResourceLoader(streamResource: StreamResource.mock(data: expectedData),
                            taskDidFail: { resultErrorFuncCheck.call($0) },
                            keyDidLoad: { keyFuncCheck.call() })
        schemeHandler.schemeTypeStub = .master
        let url = URL.mock()
        let avResourceLoader = AVAssetResourceLoader.mock(url: url)
        let requestInfo = AVAssetResourceLoadingRequest.mockRequestInfo(infoURL: url)
        let loadingRequest = AVAssetResourceLoadingRequest.mockWithCustomSetup(with: avResourceLoader, requestInfo: requestInfo)
        
        // WHEN
        let requestShouldWait = resourceLoader.resourceLoader(avResourceLoader,
                                                              shouldWaitForLoadingOfRequestedResource: loadingRequest)
        
        // THEN
        XCTAssertTrue(requestShouldWait)
        XCTAssertEqual(loadingRequest.setupFuncDidCall, true)
        XCTAssertNil(resultErrorFuncCheck.arguments)
        XCTAssertFalse(keyFuncCheck.wasCalled())
        XCTAssertEqual(masterParser.adjustFuncCheck.arguments?.0, expectedData)
    }
    
    func test_CheckPlaylistResource_ResourceRequestFailed_TaskDidFail() {
        // GIVEN
        let mockError: ResourceLoadingError = .unknown
        let expectedError: ResourceLoadingError = .custom(.init(error: mockError))
        let resultErrorFuncCheck = FuncCheck<ResourceLoadingError>()
        let keyFuncCheck = EmptyFuncCheck()
        requestable.completionHandlerStub = (nil, nil, mockError)
        requestable.dataTaskStub = .mock()
        masterParser.adjustStub = .failure(.dataConversion)
        setupResourceLoader(taskDidFail: { resultErrorFuncCheck.call($0) },
                            keyDidLoad: { keyFuncCheck.call() })
        schemeHandler.schemeTypeStub = .variant
        let url = URL.mock()
        let avResourceLoader = AVAssetResourceLoader.mock(url: url)
        let requestInfo = AVAssetResourceLoadingRequest.mockRequestInfo(infoURL: url)
        let loadingRequest = AVAssetResourceLoadingRequest.mockWithCustomSetup(with: avResourceLoader, requestInfo: requestInfo)
        let _ = resourceLoader.resourceLoader(avResourceLoader,
                                              shouldWaitForLoadingOfRequestedResource: loadingRequest)
        
        // WHEN
        let requestShouldWait = resourceLoader.resourceLoader(avResourceLoader,
                                                              shouldWaitForLoadingOfRequestedResource: loadingRequest)
        
        // THEN
        XCTAssertTrue(requestShouldWait)
        XCTAssertNil(loadingRequest.setupFuncDidCall)
        XCTAssertTrue(resultErrorFuncCheck.wasCalled(with: expectedError))
        XCTAssertFalse(keyFuncCheck.wasCalled())
    }
    
    func test_CheckPlaylistResource_ResourceHasWrongData_TaskDidFail() {
        // GIVEN
        let expectedParserError: M3U8Error = .dataConversion
        let expectedError: ResourceLoadingError = .m3u8(expectedParserError)
        let resultErrorFuncCheck = FuncCheck<ResourceLoadingError>()
        let keyFuncCheck = EmptyFuncCheck()
        let expectedData = Data.mock(string: "expected_data")
        playlistParser.adjustStub = .failure(expectedParserError)
        masterParser.adjustStub = .failure(.dataConversion)
        setupResourceLoader(streamResource: StreamResource.mock(),
                            taskDidFail: { resultErrorFuncCheck.call($0) },
                            keyDidLoad: { keyFuncCheck.call() })
        schemeHandler.schemeTypeStub = .variant
        let url = URL.mock()
        let mockResponse: HTTPURLResponse = .mock(url: url)
        requestable.completionHandlerStub = (expectedData, mockResponse, nil)
        requestable.dataTaskStub = .mock()
        let avResourceLoader = AVAssetResourceLoader.mock(url: url)
        let requestInfo = AVAssetResourceLoadingRequest.mockRequestInfo(infoURL: url)
        let loadingRequest = AVAssetResourceLoadingRequest.mockWithCustomSetup(with: avResourceLoader, requestInfo: requestInfo)
        let _ = resourceLoader.resourceLoader(avResourceLoader,
                                              shouldWaitForLoadingOfRequestedResource: loadingRequest)
        
        // WHEN
        let requestShouldWait = resourceLoader.resourceLoader(avResourceLoader,
                                                              shouldWaitForLoadingOfRequestedResource: loadingRequest)
        
        // THEN
        XCTAssertTrue(requestShouldWait)
        XCTAssertNil(loadingRequest.setupFuncDidCall)
        XCTAssertTrue(resultErrorFuncCheck.wasCalled(with: expectedError))
        XCTAssertFalse(keyFuncCheck.wasCalled())
        XCTAssertEqual(playlistParser.adjustFuncCheck.arguments?.0, expectedData)
        XCTAssertEqual(playlistParser.adjustFuncCheck.arguments?.1, url)
    }
    
    func test_CheckPlaylistResource_ResourceHasValidData_ResourceSetupWasCalled() {
        // GIVEN
        let resultErrorFuncCheck = FuncCheck<ResourceLoadingError>()
        let keyFuncCheck = EmptyFuncCheck()
        let expectedData = Data.mock(string: "expected_data")
        playlistParser.adjustStub = .success(.mock())
        setupResourceLoader(streamResource: StreamResource.mock(),
                            taskDidFail: { resultErrorFuncCheck.call($0) },
                            keyDidLoad: { keyFuncCheck.call() })
        schemeHandler.schemeTypeStub = .master
        let url = URL.mock()
        let mockResponse: HTTPURLResponse = .mock(url: url)
        requestable.completionHandlerStub = (expectedData, mockResponse, nil)
        requestable.dataTaskStub = .mock()
        let avResourceLoader = AVAssetResourceLoader.mock(url: url)
        let requestInfo = AVAssetResourceLoadingRequest.mockRequestInfo(infoURL: url)
        let loadingRequest = AVAssetResourceLoadingRequest.mockWithCustomSetup(with: avResourceLoader, requestInfo: requestInfo)
        let _ = resourceLoader.resourceLoader(avResourceLoader,
                                              shouldWaitForLoadingOfRequestedResource: loadingRequest)
        schemeHandler.schemeTypeStub = .variant
        
        // WHEN
        let requestShouldWait = resourceLoader.resourceLoader(avResourceLoader,
                                                              shouldWaitForLoadingOfRequestedResource: loadingRequest)
        
        // THEN
        XCTAssertTrue(requestShouldWait)
        XCTAssertEqual(loadingRequest.setupFuncDidCall, true)
        XCTAssertNil(resultErrorFuncCheck.arguments)
        XCTAssertFalse(keyFuncCheck.wasCalled())
        XCTAssertEqual(playlistParser.adjustFuncCheck.arguments?.0, expectedData)
        XCTAssertEqual(playlistParser.adjustFuncCheck.arguments?.1, url)
        XCTAssertNotNil(masterParser.adjustFuncCheck.arguments)
    }
    
    func test_CheckPlaylistResource_WithoutMasterFile_ResourceSetupWasCalled() {
        // GIVEN
        let resultErrorFuncCheck = FuncCheck<ResourceLoadingError>()
        let keyFuncCheck = EmptyFuncCheck()
        let expectedData = Data.mock(string: "expected_data")
        playlistParser.adjustStub = .success(.mock())
        let variantChunkKey = "#EXTINF"
        setupResourceLoader(streamResource: StreamResource.mock(data: .mock(string: variantChunkKey)),
                            taskDidFail: { resultErrorFuncCheck.call($0) },
                            keyDidLoad: { keyFuncCheck.call() })
        schemeHandler.schemeTypeStub = .variant
        let url = URL.mock()
        let mockResponse: HTTPURLResponse = .mock(url: url)
        requestable.completionHandlerStub = (expectedData, mockResponse, nil)
        requestable.dataTaskStub = .mock()
        let avResourceLoader = AVAssetResourceLoader.mock(url: url)
        let requestInfo = AVAssetResourceLoadingRequest.mockRequestInfo(infoURL: url)
        let loadingRequest = AVAssetResourceLoadingRequest.mockWithCustomSetup(with: avResourceLoader, requestInfo: requestInfo)
        let _ = resourceLoader.resourceLoader(avResourceLoader,
                                              shouldWaitForLoadingOfRequestedResource: loadingRequest)
        
        // WHEN
        let requestShouldWait = resourceLoader.resourceLoader(avResourceLoader,
                                                              shouldWaitForLoadingOfRequestedResource: loadingRequest)
        
        // THEN
        XCTAssertTrue(requestShouldWait)
        XCTAssertEqual(loadingRequest.setupFuncDidCall, true)
        XCTAssertNil(resultErrorFuncCheck.arguments)
        XCTAssertFalse(keyFuncCheck.wasCalled())
        XCTAssertEqual(playlistParser.adjustFuncCheck.arguments?.0, expectedData)
        XCTAssertEqual(playlistParser.adjustFuncCheck.arguments?.1, url)
        XCTAssertNil(masterParser.adjustFuncCheck.arguments)
    }
}
