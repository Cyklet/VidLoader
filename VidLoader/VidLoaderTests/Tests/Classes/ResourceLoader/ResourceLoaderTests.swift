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
    }
    
    private func setupResourceLoader(streamResource: StreamResource = .mock(),
                                     schemeHandler: MockSchemeHandler = .init(),
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
    
    func test_CheckKeyResource_KeyExist_ResourceSetupWasCalled() {
        // GIVEN
        var keyDidLoad = false
        var schemeHandler = MockSchemeHandler()
        schemeHandler.persistentKeyStub = Data.mock(string: "random_data")
        setupResourceLoader(schemeHandler: schemeHandler, keyDidLoad: { keyDidLoad = true })
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
        XCTAssertTrue(keyDidLoad)
    }
    
    func test_CheckMasterResource_ResourceHasWrongData_TaskDidFail() {
        // GIVEN
        let expectedParserError: M3U8Error = .dataConversion
        let expectedError: ResourceLoadingError = .m3u8(expectedParserError)
        var resultError: ResourceLoadingError?
        var keyDidLoad = false
        let expectedData = Data.mock(string: "expected_data")
        masterParser.adjustStub = .failure(expectedParserError)
        setupResourceLoader(streamResource: StreamResource.mock(data: expectedData),
                            taskDidFail: { error in resultError = error },
                            keyDidLoad: { keyDidLoad = true })
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
        XCTAssertEqual(expectedError, resultError)
        XCTAssertFalse(keyDidLoad)
        XCTAssertEqual(masterParser.adjustFuncCheck.arguments, expectedData)
    }
    
    func test_CheckMasterResource_ResourceHasValidData_ResourceSetupWasCalled() {
        // GIVEN
        var resultError: ResourceLoadingError?
        var keyDidLoad = false
        let expectedData = Data.mock(string: "expected_data")
        masterParser.adjustStub = .success(expectedData)
        setupResourceLoader(streamResource: StreamResource.mock(data: expectedData),
                            taskDidFail: { error in resultError = error },
                            keyDidLoad: { keyDidLoad = true })
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
        XCTAssertNil(resultError)
        XCTAssertFalse(keyDidLoad)
        XCTAssertEqual(masterParser.adjustFuncCheck.arguments, expectedData)
    }
    
    func test_CheckPlaylistResource_ResourceRequestFailed_TaskDidFail() {
        // GIVEN
        let mockError: ResourceLoadingError = .unknown
        let expectedError: ResourceLoadingError = .custom(.init(error: mockError))
        var resultError: ResourceLoadingError?
        var keyDidLoad = false
        requestable.completionHandlerStub = (nil, nil, mockError)
        requestable.dataTaskStub = .mock()
        masterParser.adjustStub = .failure(.dataConversion)
        setupResourceLoader(taskDidFail: { error in resultError = error },
                            keyDidLoad: { keyDidLoad = true })
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
        XCTAssertEqual(resultError, expectedError)
        XCTAssertFalse(keyDidLoad)
    }
    
    func test_CheckPlaylistResource_ResourceHasWrongData_TaskDidFail() {
        // GIVEN
        let expectedParserError: M3U8Error = .dataConversion
        let expectedError: ResourceLoadingError = .m3u8(expectedParserError)
        var resultError: ResourceLoadingError?
        var keyDidLoad = false
        let expectedData = Data.mock(string: "expected_data")
        playlistParser.adjustStub = .failure(expectedParserError)
        masterParser.adjustStub = .failure(.dataConversion)
        setupResourceLoader(streamResource: StreamResource.mock(),
                            taskDidFail: { error in resultError = error },
                            keyDidLoad: { keyDidLoad = true })
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
        XCTAssertEqual(expectedError, resultError)
        XCTAssertFalse(keyDidLoad)
        XCTAssertEqual(playlistParser.adjustFuncCheck.arguments?.0, expectedData)
        XCTAssertEqual(playlistParser.adjustFuncCheck.arguments?.1, url)
    }
    
    func test_CheckPlaylistResource_ResourceHasValidData_ResourceSetupWasCalled() {
        // GIVEN
        var resultError: ResourceLoadingError?
        var keyDidLoad = false
        let expectedData = Data.mock(string: "expected_data")
        playlistParser.adjustStub = .success(.mock())
        setupResourceLoader(streamResource: StreamResource.mock(),
                            taskDidFail: { error in resultError = error },
                            keyDidLoad: { keyDidLoad = true })
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
        XCTAssertNil(resultError)
        XCTAssertFalse(keyDidLoad)
        XCTAssertEqual(playlistParser.adjustFuncCheck.arguments?.0, expectedData)
        XCTAssertEqual(playlistParser.adjustFuncCheck.arguments?.1, url)
        XCTAssertNotNil(masterParser.adjustFuncCheck.arguments)
    }
    
    func test_CheckPlaylistResource_WithoutMasterFile_ResourceSetupWasCalled() {
        // GIVEN
        var resultError: ResourceLoadingError?
        var keyDidLoad = false
        let expectedData = Data.mock(string: "expected_data")
        playlistParser.adjustStub = .success(.mock())
        let variantChunkKey = "#EXTINF"
        setupResourceLoader(streamResource: StreamResource.mock(data: .mock(string: variantChunkKey)),
                            taskDidFail: { error in resultError = error },
                            keyDidLoad: { keyDidLoad = true })
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
        XCTAssertNil(resultError)
        XCTAssertFalse(keyDidLoad)
        XCTAssertEqual(playlistParser.adjustFuncCheck.arguments?.0, expectedData)
        XCTAssertEqual(playlistParser.adjustFuncCheck.arguments?.1, url)
        XCTAssertNil(masterParser.adjustFuncCheck.arguments)
    }
}
