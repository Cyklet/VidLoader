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
    private var parser: MockedParser!
    private var requestable: MockedRequestable!
    private var schemeHandler: MockedSchemeHandler!
    private var resourceLoader: ResourceLoader!
    
    override func setUp() {
        super.setUp()
        
        parser = MockedParser()
        requestable = MockedRequestable()
    }
    
    private func setupResourceLoader(streamResource: StreamResource = .mocked(),
                                     schemeHandler: MockedSchemeHandler = .init(),
                                     taskDidFail: @escaping Completion<ResourceLoadingError> = { _ in },
                                     assetDidLoad: @escaping () -> Void = { }) {
        resourceLoaderObserver = ResourceLoaderObserver(taskDidFail: taskDidFail,
                                                        assetDidLoad: assetDidLoad)
        resourceLoader = ResourceLoader(observer: resourceLoaderObserver,
                                        streamResource: streamResource,
                                        parser: parser,
                                        requestable: requestable,
                                        schemeHandler: schemeHandler)
    }
    
    func test_CheckKeyResource_KeyExist_ResourceSetupWasCalled() {
        // GIVEN
        var assetDidLoad = false
        var schemeHandler = MockedSchemeHandler()
        schemeHandler.persistentKeyStub = Data.mocked(string: "random_data")
        setupResourceLoader(schemeHandler: schemeHandler, assetDidLoad: { assetDidLoad = true })
        let url = URL.mocked()
        let avResourceLoader = AVAssetResourceLoader.mocked(url: url)
        let requestInfo = AVAssetResourceLoadingRequest.mockedRequestInfo(infoURL: url)
        let loadingRequest = AVAssetResourceLoadingRequest.mocked(with: avResourceLoader, requestInfo: requestInfo)
        
        // WHEN
        let requestShouldWait = resourceLoader.resourceLoader(avResourceLoader,
                                                              shouldWaitForLoadingOfRequestedResource: loadingRequest)
        
        // THEN
        XCTAssertTrue(requestShouldWait)
        XCTAssertEqual(loadingRequest.setupFuncDidCall, true)
        XCTAssertTrue(assetDidLoad)
    }
    
    func test_CheckMasterResource_ResourceHasWrongData_TaskDidFail() {
        // GIVEN
        let expectedParserError: M3U8Error = .dataConversion
        let expectedError: ResourceLoadingError = .m3u8(expectedParserError)
        var resultError: ResourceLoadingError?
        var assetDidLoad = false
        let expectedData = Data.mocked(string: "expected_data")
        setupResourceLoader(streamResource: StreamResource.mocked(data: expectedData),
                            taskDidFail: { error in resultError = error },
                            assetDidLoad: { assetDidLoad = true })
        parser.adjustStub = .failure(expectedParserError)
        let url = URL.mocked()
        let avResourceLoader = AVAssetResourceLoader.mocked(url: url)
        let requestInfo = AVAssetResourceLoadingRequest.mockedRequestInfo(infoURL: url)
        let loadingRequest = AVAssetResourceLoadingRequest.mocked(with: avResourceLoader, requestInfo: requestInfo)
        
        // WHEN
        let requestShouldWait = resourceLoader.resourceLoader(avResourceLoader,
                                                              shouldWaitForLoadingOfRequestedResource: loadingRequest)
        
        // THEN
        XCTAssertTrue(requestShouldWait)
        XCTAssertNil(loadingRequest.setupFuncDidCall)
        XCTAssertEqual(expectedError, resultError)
        XCTAssertFalse(assetDidLoad)
        XCTAssertTrue(parser.adjustFunCheck.wasCalled(with: expectedData))
    }
    
    func test_CheckMasterResource_ResourceHasValidData_ResourceSetupWasCalled() {
        // GIVEN
        var resultError: ResourceLoadingError?
        var assetDidLoad = false
        let expectedData = Data.mocked(string: "expected_data")
        setupResourceLoader(streamResource: StreamResource.mocked(data: expectedData),
                            taskDidFail: { error in resultError = error },
                            assetDidLoad: { assetDidLoad = true })
        parser.adjustStub = .success(expectedData)
        let url = URL.mocked()
        let avResourceLoader = AVAssetResourceLoader.mocked(url: url)
        let requestInfo = AVAssetResourceLoadingRequest.mockedRequestInfo(infoURL: url)
        let loadingRequest = AVAssetResourceLoadingRequest.mocked(with: avResourceLoader, requestInfo: requestInfo)
        
        // WHEN
        let requestShouldWait = resourceLoader.resourceLoader(avResourceLoader,
                                                              shouldWaitForLoadingOfRequestedResource: loadingRequest)
        
        // THEN
        XCTAssertTrue(requestShouldWait)
        XCTAssertEqual(loadingRequest.setupFuncDidCall, true)
        XCTAssertNil(resultError)
        XCTAssertFalse(assetDidLoad)
        XCTAssertTrue(parser.adjustFunCheck.wasCalled(with: expectedData))
    }
    
    func test_CheckPlaylistResource_ResourceRequestFailed_TaskDidFail() {
        // GIVEN
        let mockedError: ResourceLoadingError = .unknown
        let expectedError: ResourceLoadingError = .custom(mockedError)
        var resultError: ResourceLoadingError?
        var assetDidLoad = false
        requestable.completionHandlerStub = (nil, nil, mockedError)
        requestable.dataTaskStub = .mocked()
        setupResourceLoader(taskDidFail: { error in resultError = error },
                            assetDidLoad: { assetDidLoad = true })
        let url = URL.mocked()
        let avResourceLoader = AVAssetResourceLoader.mocked(url: url)
        let requestInfo = AVAssetResourceLoadingRequest.mockedRequestInfo(infoURL: url)
        let loadingRequest = AVAssetResourceLoadingRequest.mocked(with: avResourceLoader, requestInfo: requestInfo)
        let _ = resourceLoader.resourceLoader(avResourceLoader,
                                              shouldWaitForLoadingOfRequestedResource: loadingRequest)
        
        // WHEN
        let requestShouldWait = resourceLoader.resourceLoader(avResourceLoader,
                                                              shouldWaitForLoadingOfRequestedResource: loadingRequest)
        
        // THEN
        XCTAssertTrue(requestShouldWait)
        XCTAssertNil(loadingRequest.setupFuncDidCall)
        XCTAssertEqual(resultError, expectedError)
        XCTAssertFalse(assetDidLoad)
    }
    
    func test_CheckPlaylistResource_ResourceHasWrongData_TaskDidFail() {
        // GIVEN
        let expectedParserError: M3U8Error = .dataConversion
        let expectedError: ResourceLoadingError = .m3u8(expectedParserError)
        var resultError: ResourceLoadingError?
        var assetDidLoad = false
        let expectedData = Data.mocked(string: "expected_data")
        setupResourceLoader(streamResource: StreamResource.mocked(data: expectedData),
                            taskDidFail: { error in resultError = error },
                            assetDidLoad: { assetDidLoad = true })
        parser.adjustStub = .failure(expectedParserError)
        let url = URL.mocked()
        let mockedResponse: HTTPURLResponse = .mocked(url: url)
        requestable.completionHandlerStub = (.mocked(), mockedResponse, nil)
        requestable.dataTaskStub = .mocked()
        let avResourceLoader = AVAssetResourceLoader.mocked(url: url)
        let requestInfo = AVAssetResourceLoadingRequest.mockedRequestInfo(infoURL: url)
        let loadingRequest = AVAssetResourceLoadingRequest.mocked(with: avResourceLoader, requestInfo: requestInfo)
        let _ = resourceLoader.resourceLoader(avResourceLoader,
                                              shouldWaitForLoadingOfRequestedResource: loadingRequest)
        
        // WHEN
        let requestShouldWait = resourceLoader.resourceLoader(avResourceLoader,
                                                              shouldWaitForLoadingOfRequestedResource: loadingRequest)
        
        // THEN
        XCTAssertTrue(requestShouldWait)
        XCTAssertNil(loadingRequest.setupFuncDidCall)
        XCTAssertEqual(expectedError, resultError)
        XCTAssertFalse(assetDidLoad)
        XCTAssertTrue(parser.adjustFunCheck.wasCalled(with: expectedData))
    }
    
    func test_CheckPlaylistResource_ResourceHasValidData_ResourceSetupWasCalled() {
        // GIVEN
        var resultError: ResourceLoadingError?
        var assetDidLoad = false
        let expectedData = Data.mocked(string: "expected_data")
        setupResourceLoader(streamResource: StreamResource.mocked(data: expectedData),
                            taskDidFail: { error in resultError = error },
                            assetDidLoad: { assetDidLoad = true })
        parser.adjustStub = .success(expectedData)
        let url = URL.mocked()
        let mockedResponse: HTTPURLResponse = .mocked(url: url)
        requestable.completionHandlerStub = (.mocked(), mockedResponse, nil)
        requestable.dataTaskStub = .mocked()
        let avResourceLoader = AVAssetResourceLoader.mocked(url: url)
        let requestInfo = AVAssetResourceLoadingRequest.mockedRequestInfo(infoURL: url)
        let loadingRequest = AVAssetResourceLoadingRequest.mocked(with: avResourceLoader, requestInfo: requestInfo)
        let _ = resourceLoader.resourceLoader(avResourceLoader,
                                              shouldWaitForLoadingOfRequestedResource: loadingRequest)
        
        // WHEN
        let requestShouldWait = resourceLoader.resourceLoader(avResourceLoader,
                                                              shouldWaitForLoadingOfRequestedResource: loadingRequest)
        
        // THEN
        XCTAssertTrue(requestShouldWait)
        XCTAssertEqual(loadingRequest.setupFuncDidCall, true)
        XCTAssertNil(resultError)
        XCTAssertFalse(assetDidLoad)
        XCTAssertTrue(parser.adjustFunCheck.wasCalled(with: expectedData))
    }
}
