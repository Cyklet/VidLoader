//
//  KeyLoaderTests.swift
//  VidLoaderTests
//
//  Created by Petre on 12/6/19.
//  Copyright © 2019 Petre. All rights reserved.
//
import XCTest
import AVFoundation
@testable import VidLoader

final class KeyLoaderTests: XCTestCase {
    private var keyLoader: KeyLoader!
    private var schemeHandler: MockSchemeHandler!
    
    override func setUp() {
        super.setUp()
        
        schemeHandler = MockSchemeHandler()
    }
    
    func test_LoadKey_NoKeyScheme_NoSetupCalledInLoadingRequest() {
        // GIVEN
        let expectedURL = URL.mock()
        let requestInfo = AVAssetResourceLoadingRequest.mockRequestInfo(infoURL: expectedURL)
        let loadingRequest = AVAssetResourceLoadingRequest.mockWithCustomSetup(requestInfo: requestInfo)
        schemeHandler.persistentKeyStub = nil
        keyLoader = KeyLoader(schemeHandler: schemeHandler)
        
        // WHEN
        let resultShouldWait = keyLoader.resourceLoader(.mock(),
                                                        shouldWaitForLoadingOfRequestedResource: loadingRequest)
        
        // THEN
        XCTAssertTrue(resultShouldWait)
        XCTAssertTrue(schemeHandler.persistentKeyFuncCheck.wasCalled(with: expectedURL))
        XCTAssertNil(loadingRequest.setupFuncDidCall)
    }
    
    func test_LoadKey_WithKeyScheme_SetupCalledInLoadingRequest() {
        // GIVEN
        let expectedURL = URL.mock()
        let requestInfo = AVAssetResourceLoadingRequest.mockRequestInfo(infoURL: expectedURL)
        let loadingRequest = AVAssetResourceLoadingRequest.mockWithCustomSetup(requestInfo: requestInfo)
        let mockData = Data.mock(string: "mock_key_data")
        schemeHandler.persistentKeyStub = mockData
        keyLoader = KeyLoader(schemeHandler: schemeHandler)
        
        // WHEN
        let resultShouldWait = keyLoader.resourceLoader(.mock(),
                                                        shouldWaitForLoadingOfRequestedResource: loadingRequest)
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.01)
        
        // THEN
        XCTAssertTrue(resultShouldWait)
        XCTAssertTrue(schemeHandler.persistentKeyFuncCheck.wasCalled(with: expectedURL))
        XCTAssertEqual(loadingRequest.setupFuncDidCall, true)
    }
}
