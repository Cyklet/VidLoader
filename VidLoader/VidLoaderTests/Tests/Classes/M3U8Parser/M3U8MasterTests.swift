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
    private var parser: StreamContentRepresentable!
    
    override func setUp() {
        super.setUp()
        
        parser = M3U8Master()
    }
    
    func test_AdjustMasterScheme_OriginalSchemeExist_SchemeIsReplaced() {
        // GIVEN
        let path = "random_path"
        let givenString = "\(SchemeType.original.rawValue)://\(path)"
        let expectedResult: Result<String, M3U8Error> = .success("\(SchemeType.custom.rawValue)://\(path)")
        var finalResult: Result<String, M3U8Error>?
        
        // WHEN
        parser.adjust(response: givenString, completion: { result in
            finalResult = result
        })
        
        // THEN
        XCTAssertEqual(expectedResult, finalResult)
    }
    
    func test_AdjustMasterScheme_OriginalSchemeNotExist_SchemeIsNotReplaced() {
        // GIVEN
        let path = "random_path"
        let givenString = "wrong_key://\(path)"
        let expectedResult: Result<String, M3U8Error> = .failure(.dataConversion)
        var finalResult: Result<String, M3U8Error>?
        
        // WHEN
        parser.adjust(response: givenString, completion: { result in
            finalResult = result
        })
        
        // THEN
        XCTAssertEqual(expectedResult, finalResult)
    }
}
