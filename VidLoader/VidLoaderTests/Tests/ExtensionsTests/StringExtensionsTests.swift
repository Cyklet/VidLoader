//
//  StringExtensionsTests.swift
//  VidLoaderTests
//
//  Created by Petre on 12/10/19.
//  Copyright © 2019 Petre. All rights reserved.
//

import XCTest
@testable import VidLoader

final class StringExtensionsTests: XCTestCase {
    private let startSearchKey = "StartKEY"
    
    func test_ConvertStringToData_ValidData_ResultSameAsExpectation() {
        // GIVEN
        let givenString = "random\\_//string"
        let expectedData = givenString.data(using: .utf8)
        
        // WHEN
        let resultData = givenString.data
        
        // THEN
        XCTAssertEqual(expectedData, resultData)
    }
    
    func test_RemoveIllegalChars_IllegalCharsExists_ResultWillBeWithoutThem() {
        // GIVEN
        let givenString = "!@!@!@!name_-/'`1234567890-=~!@#$%^&*()_+}{{:\":>?>[[][;.]]"
        let expectedString = "name1234567890"
        
        // WHEN
        let finalString = givenString.removingIllegalCharacters
        
        // THEN
        XCTAssertEqual(expectedString, finalString)
    }
    
    func test_FindMatches_WrongRegex_ResultIsEmptyArray() {
        // GIVEN
        let expectedMatches: [String] = []
 
        // WHEN
        let resultMatches = "".matches(for: "(?<qwd1asdasdtartSeasd;''[^asd,\"]+")
        
        // THEN
        XCTAssertEqual(expectedMatches, resultMatches)
    }
    
       
    func test_FindMatches_WhenNoMatches_ResultIsEmptyArray() {
        // GIVEN
        let givenString = "prefix_gbfd,lsfmkng_wrong_string_for_test"
        let expectedMatches: [String] = []
        
        // WHEN
        let resultMatches = givenString.matches(for: "(?<=\(startSearchKey))[^\n,\"]+")
        
        // THEN
        XCTAssertEqual(expectedMatches, resultMatches)
    }
    
    
    func test_FindMatches_WhenOneMatch_ArrayIsNotEmpty() {
        // GIVEN
        let givenString = "\(startSearchKey)FindMe\"asdasdasda"
        let expectedMatches: [String] = ["FindMe"]
        
        // WHEN
        let resultMatches = givenString.matches(for: "(?<=\(startSearchKey))[^\n,\"]+")
        
        // THEN
        XCTAssertEqual(expectedMatches, resultMatches)
    }
}
