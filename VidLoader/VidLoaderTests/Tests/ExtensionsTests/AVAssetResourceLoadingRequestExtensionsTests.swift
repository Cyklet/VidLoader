//
//  AVAssetResourceLoadingRequestExtensionsTests.swift
//  VidLoaderTests
//
//  Created by Petre on 12/10/19.
//  Copyright © 2019 Petre. All rights reserved.
//

import XCTest
import AVFoundation
@testable import VidLoader

final class AVAssetResourceLoadingRequestTests: XCTestCase {

    func test_SetupLoadingRequest_InformationHasSet_RequestGotNewInformation() {
        // GIVEN
        let resourceLoading = AVAssetResourceLoadingRequest.mock(shouldSwizzle: false)
        let expectedContentType = "custom_mime"
        let expectedIsByteRangeAccessSupported = true
        let expectedContentLength = 1231
        let response: HTTPURLResponse = .mock(mimeType: expectedContentType, expectedContentLength: expectedContentLength)
        
        // WHEN
        resourceLoading.setup(response: response, data: .mock())
        
        // THEN
        XCTAssertEqual(expectedContentType, resourceLoading.contentInformationRequest?.contentType)
        XCTAssertEqual(expectedIsByteRangeAccessSupported, resourceLoading.contentInformationRequest?.isByteRangeAccessSupported)
        XCTAssertEqual(Int64(expectedContentLength), resourceLoading.contentInformationRequest?.contentLength)
    }
}
