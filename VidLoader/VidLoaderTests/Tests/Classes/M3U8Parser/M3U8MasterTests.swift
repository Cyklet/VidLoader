//
//  M3U8MasterTests.swift
//  VidLoaderTests
//
//  Created by Petre on 12/10/19.
//  Copyright © 2019 Petre. All rights reserved.
//
import XCTest
@testable import VidLoader

final class M3U8MasterTest: XCTestCase {
    private var parser: M3U8Master!
    
    override func setUp() {
        super.setUp()
        
        parser = M3U8Master()
    }
    
    func test_AdjustMasterScheme_OriginalSchemeExist_SchemeIsReplaced() {
        // GIVEN
        let path = "random_path"
        let givenString = "\(SchemeType.original.rawValue)://\(path)"
        let expectedResult: Result<Data, M3U8Error> = .success(.mock(string: "\(SchemeType.custom.rawValue)://\(path)"))
        
        // WHEN
        let finalResult: Result<Data, M3U8Error> = parser.adjust(data: .mock(string: givenString))
        
        // THEN
        XCTAssertEqual(expectedResult, finalResult)
    }
    
    func test_AdjustMasterScheme_OriginalSchemeNotExist_SchemeIsNotReplaced() {
        // GIVEN
        let givenString = "wrong_scheme://random.path.co"
        let expectedResult: Result<Data, M3U8Error> = .success(.mock(string: givenString))
        
        // WHEN
        let finalResult = parser.adjust(data: .mock(string: givenString))
        
        // THEN
        XCTAssertEqual(expectedResult, finalResult)
    }
}
