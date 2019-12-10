//
//  M3U8PlaylistTests.swift
//  VidLoaderTests
//
//  Created by Petre on 12/10/19.
//  Copyright © 2019 Petre. All rights reserved.
//

import XCTest
@testable import VidLoader

final class M3U8PlaylistTests: XCTestCase {
    private var requestable: MockRequestable!
    private var parser: StreamContentRepresentable!
    
    override func setUp() {
        super.setUp()
        
        requestable = MockRequestable()
        parser = M3U8Playlist(requestable: requestable)
    }
    
    func test_AdjustPlaylistSchemes_NoKeyFound_AdjustWillFail() {
        // GIVEN
        let givenString = "\(SchemeType.original.rawValue)://simple_path"
        let expectedResult: Result<String, M3U8Error> = .failure(.keyURLMissing)
        var finalResult: Result<String, M3U8Error>?
        
        // WHEN
        parser.adjust(response: givenString, completion: { result in
            finalResult = result
        })
        
        // THEN
        XCTAssertEqual(expectedResult, finalResult)
    }
    
    func test_AdjustPlaylistSchemes_KeyURLWrong_AdjustWillFail() {
        // GIVEN
        let givenString = "URI=\"broken url\""
        let expectedResult: Result<String, M3U8Error> = .failure(.keyURLMissing)
        var finalResult: Result<String, M3U8Error>?
        
        // WHEN
        parser.adjust(response: givenString, completion: { result in
            finalResult = result
        })
        
        // THEN
        XCTAssertEqual(expectedResult, finalResult)
    }
    
    func test_AdjustPlaylistSchemes_KeyDownloadFailed_AdjustWillFail() {
        // GIVEN
        let givenString = "URI=\"https://random_url\""
        let givenError: DownloadError = .unknown
        let expectedResult: Result<String, M3U8Error> = .failure(.custom(.init(error: givenError)))
        var finalResult: Result<String, M3U8Error>?
        requestable.dataTaskStub = .mock()
        requestable.completionHandlerStub = (nil, nil, givenError)
        
        // WHEN
        parser.adjust(response: givenString, completion: { result in
            finalResult = result
        })
        
        // THEN
        XCTAssertEqual(expectedResult, finalResult)
    }
    
    
    func test_AdjustPlaylistSchemes_KeyDownloadSucceeded_AdjustWillSucceed() {
        // GIVEN
        let givenString = "URI=\"https://random_url\""
        let base64String = "Ym9uZF9qYW1lc19ib25k"
        let expectedKey = "URI=\"\(SchemeType.key.rawValue):\(base64String)\""
        let expectedResult: Result<String, M3U8Error> = .success(expectedKey)
        var finalResult: Result<String, M3U8Error>?
        requestable.dataTaskStub = .mock()
        let expectedData = Data(base64Encoded: base64String)
        requestable.completionHandlerStub = (expectedData, HTTPURLResponse.mock(), nil)
        
        // WHEN
        parser.adjust(response: givenString, completion: { result in
            finalResult = result
        })
        
        // THEN
        XCTAssertEqual(expectedResult, finalResult)
    }
}
