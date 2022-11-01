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
        let resourceLoading = AVAssetResourceLoadingRequest.mockWithCustomContentInfoRequest()
        let expectedContentType = "custom_type"
        let expectedIsByteRangeAccessSupported = true
        let expectedContentLength = 1231
        let expectedEntireLengthAvailableOnDemand = true
        let response: HTTPURLResponse = .mock(mimeType: expectedContentType, expectedContentLength: expectedContentLength)
        resourceLoading.contentInformationRequestStub = .mock(loadingRequest: resourceLoading, allowedContentTypes: nil)
        
        // WHEN
        resourceLoading.setup(response: response, data: .mock(), isEntireLengthAvailableOnDemand: true)
        
        // THEN
        XCTAssertEqual(expectedContentType, resourceLoading.contentInformationRequest?.contentType)
        XCTAssertEqual(expectedIsByteRangeAccessSupported, resourceLoading.contentInformationRequest?.isByteRangeAccessSupported)
        XCTAssertEqual(Int64(expectedContentLength), resourceLoading.contentInformationRequest?.contentLength)
        if #available(iOS 16, *) {
            XCTAssertEqual(expectedEntireLengthAvailableOnDemand, resourceLoading.contentInformationRequest?.isEntireLengthAvailableOnDemand)
        }
    }
    
    func test_SetupLoadingRequest_AllowedTypesAreEmpty_ContentTypeIsNil() {
        // GIVEN
        let resourceLoading = AVAssetResourceLoadingRequest.mockWithCustomContentInfoRequest()
        let expectedContentType: String? = nil
        let givenContentType = "custom_type"
        let expectedEntireLengthAvailableOnDemand = false
        let response: HTTPURLResponse = .mock(mimeType: givenContentType, expectedContentLength: 10)
        resourceLoading.contentInformationRequestStub = .mock(loadingRequest: resourceLoading, allowedContentTypes: [])
        
        // WHEN
        resourceLoading.setup(response: response, data: .mock(), isEntireLengthAvailableOnDemand: false)
        
        // THEN
        XCTAssertEqual(expectedContentType, resourceLoading.contentInformationRequest?.contentType)
        if #available(iOS 16, *) {
            XCTAssertEqual(expectedEntireLengthAvailableOnDemand, resourceLoading.contentInformationRequest?.isEntireLengthAvailableOnDemand)
        }
    }
    
    func test_SetupLoadingRequest_AllowedTypesDoNotContainGivenType_ContentTypeIsNil() {
        // GIVEN
        let resourceLoading = AVAssetResourceLoadingRequest.mockWithCustomContentInfoRequest()
        let expectedContentType: String? = nil
        let givenContentType = "custom_type"
        let allowedTypes = ["random_type1", "random_type2"]
        let expectedEntireLengthAvailableOnDemand = true
        let response: HTTPURLResponse = .mock(mimeType: givenContentType, expectedContentLength: 10)
        resourceLoading.contentInformationRequestStub = .mock(loadingRequest: resourceLoading, allowedContentTypes: allowedTypes as NSArray)
        
        // WHEN
        resourceLoading.setup(response: response, data: .mock(), isEntireLengthAvailableOnDemand: true)
        
        // THEN
        XCTAssertEqual(expectedContentType, resourceLoading.contentInformationRequest?.contentType)
        if #available(iOS 16, *) {
            XCTAssertEqual(expectedEntireLengthAvailableOnDemand, resourceLoading.contentInformationRequest?.isEntireLengthAvailableOnDemand)
        }
    }
    
    func test_SetupLoadingRequest_AllowedTypesContainGivenType_ContentTypeIsNil() {
        // GIVEN
        let resourceLoading = AVAssetResourceLoadingRequest.mockWithCustomContentInfoRequest()
        let givenContentType = "custom_type"
        let expectedContentType = givenContentType
        let allowedTypes = ["random_type1", givenContentType]
        let expectedEntireLengthAvailableOnDemand = false
        let response: HTTPURLResponse = .mock(mimeType: givenContentType, expectedContentLength: 10)
        resourceLoading.contentInformationRequestStub = .mock(loadingRequest: resourceLoading, allowedContentTypes: allowedTypes as NSArray)
        
        // WHEN
        resourceLoading.setup(response: response, data: .mock(), isEntireLengthAvailableOnDemand: false)
        
        // THEN
        XCTAssertEqual(expectedContentType, resourceLoading.contentInformationRequest?.contentType)
        if #available(iOS 16, *) {
            XCTAssertEqual(expectedEntireLengthAvailableOnDemand, resourceLoading.contentInformationRequest?.isEntireLengthAvailableOnDemand)
        }
    }
}
