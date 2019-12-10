//
//  DownloadErrorTests.swift
//  VidLoaderTests
//
//  Created by Petre on 12/9/19.
//  Copyright © 2019 Petre. All rights reserved.
//

import XCTest
@testable import VidLoader

final class DownloadErrorTests: XCTestCase {
 
    func test_CreateLoaderError_givenErrorIsNil_ErrorIsUnknown() {
        // GIVEN
        let expectedError: DownloadError = .unknown
        
        // WHEN
        let resultError = DownloadError(error: nil)
        
        // THEN
        XCTAssertEqual(expectedError, resultError)
    }
    
    func test_CreateLoaderError_givenErrorExist_ErrorIsConvertedFromGiven() {
        // GIVEN
        let givenError = NSError(domain: "custom_damain", code: -983, userInfo: nil)
        let expectedError: DownloadError = .custom(VidLoaderError(error: givenError))
        
        // WHEN
        let resultError = DownloadError(error: givenError)
        
        // THEN
        XCTAssertEqual(expectedError, resultError)
    }
    
}
