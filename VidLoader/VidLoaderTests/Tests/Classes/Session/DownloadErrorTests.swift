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
        let givenError = NSError.mock()
        let expectedError: DownloadError = .custom(VidLoaderError(error: givenError))
        
        // WHEN
        let resultError = DownloadError(error: givenError)
        
        // THEN
        XCTAssertEqual(expectedError, resultError)
    }
    
    func test_GenerateTwoErrors_BothHaveUnknownType_ErrorsAreEqual() {
        // GIVEN
        let firstError: DownloadError = .unknown
        let secondError: DownloadError = .unknown
        
        // WHEN
        let areErrorsEqual = firstError == secondError
        
        // THEN
        XCTAssertTrue(areErrorsEqual)
    }
    
    func test_GenerateTwoErrors_BothAreTaskErrors_ErrorsAreEqual() {
        // GIVEN
        let firstError: DownloadError = .taskNotCreated
        let secondError: DownloadError = .taskNotCreated
        
        // WHEN
        let areErrorsEqual = firstError == secondError
        
        // THEN
        XCTAssertTrue(areErrorsEqual)
    }
    
    func test_GenerateTwoErrors_BothAreCustomErrors_ErrorsAreEqual() {
        // GIVEN
        let firstError: DownloadError = .custom(VidLoaderError(error: NSError.mock(code: 1)))
        let secondError: DownloadError = .custom(VidLoaderError(error: NSError.mock(code: 2)))
        
        // WHEN
        let areErrorsEqual = firstError == secondError
        
        // THEN
        XCTAssertTrue(areErrorsEqual)
    }
    
    func test_GenerateTwoErrors_ErrorsAreDifferent_ErrorsAreNotEqual() {
        // GIVEN
        let firstError: DownloadError = .custom(VidLoaderError(error: NSError.mock(code: 1)))
        let secondError: DownloadError = .unknown
        
        // WHEN
        let areErrorsEqual = firstError == secondError
        
        // THEN
        XCTAssertFalse(areErrorsEqual)
    }
}
