//
//  M3U8ParserTests.swift
//  VidLoaderTests
//
//  Created by Petre on 12/10/19.
//  Copyright © 2019 Petre. All rights reserved.
//

import XCTest
@testable import VidLoader

final class M3U8ParserTests: XCTestCase {
    private var parser: M3U8Parser!
    private var requestable: MockRequestable!
    private let streamInfKey = "#EXT-X-STREAM-INF"
    
    override func setUp() {
        super.setUp()
        
        requestable = MockRequestable()
        parser = M3U8Parser(requestable: requestable)
    }
    
    func test_AdjustMasterScheme_AdjustSucceed_SuccesResultAchieved() {
        // GIVEN
        let playlistString = "\(streamInfKey):\"\(SchemeType.original.rawValue)://path\""
        let expectedString = "\(streamInfKey):\"\(SchemeType.custom.rawValue)://path\""
        let givenData: Data = .mock(string: "\(playlistString) \(playlistString)")
        let expectedData: Data = .mock(string: "\(expectedString) \(expectedString)")
        let expectedResult: Result<Data, M3U8Error> = .success(expectedData)
        var finalResult: Result<Data, M3U8Error>?
        
        // WHEN
        parser.adjust(data: givenData, completion: { result in
            finalResult = result
        })
        
        // THEN
        XCTAssertEqual(expectedResult, finalResult)
    }
    
    func test_AdjustPlaylistScheme_AdjustFailed_FailedResultAchieved() {
        // GIVEN
        let givenData: Data = .mock(string: "wrong_key_data")
        let expectedResult: Result<Data, M3U8Error> = .failure(.keyURLMissing)
        var finalResult: Result<Data, M3U8Error>?
        
        // WHEN
        parser.adjust(data: givenData, completion: { result in
            finalResult = result
        })
        
        // THEN
        XCTAssertEqual(expectedResult, finalResult)
    }
}
