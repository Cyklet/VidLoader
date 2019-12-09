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
    private var schemeHandler: MockedSchemeHandler!
    
    override func setUp() {
        super.setUp()
        
        schemeHandler = MockedSchemeHandler()
    }
    
    func test_LoadKey_NoKeyScheme_NoSetupCalledInLoadingRequest() {
        // GIVEN
        let expectedURL = URL.mocked()
        let requestInfo = AVAssetResourceLoadingRequest.mockedRequestInfo(infoURL: expectedURL)
        let loadingRequest = AVAssetResourceLoadingRequest.mocked(requestInfo: requestInfo)
        schemeHandler.persistentKeyStub = nil
        keyLoader = KeyLoader(schemeHandler: schemeHandler)
        
        // WHEN
        let resultShouldWait = keyLoader.resourceLoader(.mocked(),
                                                        shouldWaitForLoadingOfRequestedResource: loadingRequest)
        
        // THEN
        XCTAssertTrue(resultShouldWait)
        XCTAssertTrue(schemeHandler.persistentKeyFunCheck.wasCalled(with: expectedURL))
        XCTAssertNil(loadingRequest.setupFuncDidCall)
    }
    
    func test_LoadKey_WithKeyScheme_SetupCalledInLoadingRequest() {
        // GIVEN
        let expectedURL = URL.mocked()
        let requestInfo = AVAssetResourceLoadingRequest.mockedRequestInfo(infoURL: expectedURL)
        let loadingRequest = AVAssetResourceLoadingRequest.mocked(requestInfo: requestInfo)
        let mockedData = Data.mocked(string: "key_mocked_data")
        schemeHandler.persistentKeyStub = mockedData
        keyLoader = KeyLoader(schemeHandler: schemeHandler)
        
        // WHEN
        let resultShouldWait = keyLoader.resourceLoader(.mocked(),
                                                        shouldWaitForLoadingOfRequestedResource: loadingRequest)
        
        // THEN
        XCTAssertTrue(resultShouldWait)
        XCTAssertTrue(schemeHandler.persistentKeyFunCheck.wasCalled(with: expectedURL))
        XCTAssertEqual(loadingRequest.setupFuncDidCall, true)
    }
}
