//
//  DataExtensionsTests.swift
//  VidLoaderTests
//
//  Created by Petre on 12/10/19.
//  Copyright © 2019 Petre. All rights reserved.
//

import XCTest
@testable import VidLoader

final class DataExtensionsTests: XCTestCase {
    func test_GetStringFromData_DataHasCorrectEncode_ResultIsEqualWithExpectation() {
        // GIVEN
        let expectedString = "expected _ string"
        let data = expectedString.data(using: .utf8)
        
        // WHEN
        let resultString = data?.string
        
        // THEN
        XCTAssertEqual(expectedString, resultString)
    }
    
    func test_GetStringFromData_DataHasIncorrectEncode_ResultIsNotEqualWithExpectation() {
        // GIVENr
        let expectedString = "ZW5jb2RlZCBfIHN0cmluZw=="
        let data = expectedString.data(using: .utf16BigEndian)
        
        // WHEN
        let resultString = data?.string
        
        // THEN
        XCTAssertNotEqual(expectedString, resultString)
    }
}
