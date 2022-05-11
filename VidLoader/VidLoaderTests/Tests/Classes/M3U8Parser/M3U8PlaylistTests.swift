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
    private var parser: PlaylistParser!
    
    override func setUp() {
        super.setUp()
        
        requestable = MockRequestable()
        parser = M3U8Playlist(requestable: requestable)
    }
    
    func test_AdjustPlaylistSchemes_WithoutEncryptionKeyInformation_AdjustWillSucceed() {
        // GIVEN
        let baseURL = URL.mock(stringURL: "https://base_url")
        let givenString = "\(SchemeType.original.rawValue)://simple_path"
        let expectedResult: Result<Data, M3U8Error> = .success(.mock(string: givenString))
        var finalResult: Result<Data, M3U8Error>?
        
        // WHEN
        parser.adjust(data: .mock(string: givenString), with: baseURL, headers: nil, completion: { result in
            finalResult = result
        })
        
        // THEN
        XCTAssertEqual(expectedResult, finalResult)
    }
    
    func test_AdjustPlaylistSchemes_WithoutEncryptionKeyKeyword_AdjustWillSucceed() {
        // GIVEN
        let baseURL = URL.mock(stringURL: "https://base_url")
        let givenString = "URI=\"random_url\""
        let expectedResult: Result<Data, M3U8Error> = .success(.mock(string: givenString))
        var finalResult: Result<Data, M3U8Error>?
        
        // WHEN
        parser.adjust(data: .mock(string: givenString), with: baseURL, headers: nil, completion: { result in
            finalResult = result
        })
        
        // THEN
        XCTAssertEqual(expectedResult, finalResult)
    }
    
    func test_AdjustPlaylistSchemes_KeyDownloadFailed_AdjustWillReturnSameResponse() {
        // GIVEN
        let baseURL = URL.mock(stringURL: "https://base_url")
        let givenString = "#EXT-X-KEYURI=\"https://random_url\""
        let givenError: DownloadError = .unknown
        let expectedResult: Result<Data, M3U8Error> = .success(givenString.data!)
        var finalResult: Result<Data, M3U8Error>?
        requestable.dataTaskStub = .mock()
        requestable.completionHandlerStub = (nil, nil, givenError)
        let givenHeaders: [String: String] = [:]
        
        // WHEN
        parser.adjust(data: .mock(string: givenString), with: baseURL, headers: givenHeaders, completion: { result in
            finalResult = result
        })
        
        // THEN
        XCTAssertEqual(expectedResult, finalResult)
        XCTAssertEqual(requestable.dataTaskFuncCheck.arguments?.allHTTPHeaderFields, nil)
    }
    
    
    func test_AdjustPlaylistSchemes_KeyDownloadSucceeded_AdjustWillSucceed() {
        // GIVEN
        let baseURL = URL.mock(stringURL: "https://base_url")
        let givenString = "#EXT-X-KEYURI=\"https://random_url\""
        let base64String = "Ym9uZF9qYW1lc19ib25k"
        let expectedKey = "#EXT-X-KEYURI=\"\(SchemeType.key.rawValue):\(base64String)\""
        let expectedResult: Result<Data, M3U8Error> = .success(.mock(string: expectedKey))
        var finalResult: Result<Data, M3U8Error>?
        requestable.dataTaskStub = .mock()
        let expectedData = Data(base64Encoded: base64String)
        requestable.completionHandlerStub = (expectedData, HTTPURLResponse.mock(), nil)
        let givenHeaders = ["User-Agent" : "Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1"]
        
        // WHEN
        parser.adjust(data: .mock(string: givenString), with: baseURL, headers: givenHeaders, completion: { result in
            finalResult = result
        })
        
        // THEN
        XCTAssertEqual(expectedResult, finalResult)
        XCTAssertEqual(requestable.dataTaskFuncCheck.arguments?.allHTTPHeaderFields, givenHeaders)
    }
    
    func test_AdjustPlaylistSchemes_RelativePaths_AdjustWillSucceed() {
        // GIVEN
        let baseURL = URL.mock(stringURL: "https://base_url")
        let baseURLString = baseURL.absoluteString
        let givenResponse = "EXT-X-PLAYLIST-TYPE:VOD\n#EXT-X-KEY:random_staff URI=\"relative_random_path\"\n#EXT-X-INDEPENDENT-SEGMENTS\n#EXT-X-MAP:URI=\"audio_english_192_0.mp4\"\n#EXTINF:5.99467,\t\r\n#EXT-X-BITRATE:194\r\naudio_english_192_1.mp4\r\n#EXTINF:6,\n/audio_english_192_2.mp4\n#EXTINF:7,\r/audio_english_192_3.mp4\r"
        let base64String = "Ym9uZF9qYW1lc19ib25k"
        let expectedResponse = "EXT-X-PLAYLIST-TYPE:VOD\n#EXT-X-KEY:random_staff URI=\"\(SchemeType.key.rawValue):\(base64String)\"\n#EXT-X-INDEPENDENT-SEGMENTS\n#EXT-X-MAP:URI=\"\(baseURLString)/audio_english_192_0.mp4\"\n#EXTINF:5.99467,\t\r\n#EXT-X-BITRATE:194\r\n\(baseURLString)/audio_english_192_1.mp4\r\n#EXTINF:6,\n\(baseURLString)/audio_english_192_2.mp4\n#EXTINF:7,\r\(baseURLString)/audio_english_192_3.mp4\r"
        let expectedResult: Result<Data, M3U8Error> = .success(.mock(string: expectedResponse))
        var finalResult: Result<Data, M3U8Error>?
        requestable.dataTaskStub = .mock()
        let expectedData = Data(base64Encoded: base64String)
        requestable.completionHandlerStub = (expectedData, HTTPURLResponse.mock(), nil)
        let givenHeaders: [String: String]? = nil
        
        // WHEN
        parser.adjust(data: .mock(string: givenResponse), with: baseURL, headers: givenHeaders, completion: { result in
            finalResult = result
        })
        
        // THEN
        XCTAssertEqual(expectedResult, finalResult)
        XCTAssertEqual(requestable.dataTaskFuncCheck.arguments?.allHTTPHeaderFields, givenHeaders)
    }
    
    func test_AdjustPlaylistSchemes_RelativePathsWithoutEncryptionKey_AdjustWillSucceed() {
        // GIVEN
        let baseURL = URL.mock(stringURL: "https://base_url")
        let baseURLString = baseURL.absoluteString
        let givenResponse = "#EXTINF:12.012,\n1920_00001.ts\n#EXTINF:12.012,\n1920_00002.ts\n#EXTINF:12.012,\n/1920_00003.ts\n#EXTINF:12.012,\n../1920_00004.ts\n#EXT-X-ENDLIST"
        let base64String = "Ym9uZF9qYW1lc19ib25k"
        let expectedResponse = "#EXTINF:12.012,\n\(baseURLString)/1920_00001.ts\n#EXTINF:12.012,\n\(baseURLString)/1920_00002.ts\n#EXTINF:12.012,\n\(baseURLString)/1920_00003.ts\n#EXTINF:12.012,\n\(baseURLString)/../1920_00004.ts\n#EXT-X-ENDLIST"
        let expectedResult: Result<Data, M3U8Error> = .success(.mock(string: expectedResponse))
        var finalResult: Result<Data, M3U8Error>?
        requestable.dataTaskStub = .mock()
        let expectedData = Data(base64Encoded: base64String)
        requestable.completionHandlerStub = (expectedData, HTTPURLResponse.mock(), nil)
        
        // WHEN
        parser.adjust(data: .mock(string: givenResponse), with: baseURL, headers: nil, completion: { result in
            finalResult = result
        })
        
        // THEN
        XCTAssertEqual(expectedResult, finalResult)
    }
    
    func test_AdjustPlaylistSchemes_URLsContainsSameNumber_AdjustWillSucceed() {
        // GIVEN
        let baseURL = URL.mock(stringURL: "https://base_url")
        let baseURLString = baseURL.absoluteString
        let givenResponse = "EXT-X-PLAYLIST-TYPE:VOD\n#EXT-X-KEY:random_staff URI=\"relative_random_path=1\"\n#EXT-X-INDEPENDENT-SEGMENTS\n#EXT-X-MAP:URI=\"audio_english_192_0.mp4\"\n#EXTINF:5.99467,\t\r\n#EXT-X-BITRATE:194\r\naudio_english_192_1.mp4\r\n#EXTINF:6,\n/audio_english_192_2.mp4\n#EXTINF:7,\r/audio_english_192_3.mp4\r\n#EXT-X-KEY:random_staff URI=\"relative_random_path=12\"\n"
        let firstKey64String = "Zmlyc3RrZXk="
        let secondKey64String = "c2Vjb25ka2V5"
        let expectedResponse = "EXT-X-PLAYLIST-TYPE:VOD\n#EXT-X-KEY:random_staff URI=\"\(SchemeType.key.rawValue):\(firstKey64String)\"\n#EXT-X-INDEPENDENT-SEGMENTS\n#EXT-X-MAP:URI=\"\(baseURLString)/audio_english_192_0.mp4\"\n#EXTINF:5.99467,\t\r\n#EXT-X-BITRATE:194\r\n\(baseURLString)/audio_english_192_1.mp4\r\n#EXTINF:6,\n\(baseURLString)/audio_english_192_2.mp4\n#EXTINF:7,\r\(baseURLString)/audio_english_192_3.mp4\r\n#EXT-X-KEY:random_staff URI=\"\(SchemeType.key.rawValue):\(secondKey64String)\"\n"
        let expectedResult: Result<Data, M3U8Error> = .success(.mock(string: expectedResponse))
        var finalResult: Result<Data, M3U8Error>?
        requestable.dataTaskStub = .mock()
        let expectedFirstKey = Data(base64Encoded: firstKey64String)!
        let expectedSecondKey = Data(base64Encoded: secondKey64String)!
        requestable.dataArrayStub = [expectedFirstKey, expectedSecondKey]
        requestable.completionHandlerStub = (nil, HTTPURLResponse.mock(), nil)
        let givenHeaders: [String: String]? = nil
        
        // WHEN
        parser.adjust(data: .mock(string: givenResponse), with: baseURL, headers: givenHeaders, completion: { result in
            finalResult = result
        })
        
        // THEN
        XCTAssertEqual(expectedResult, finalResult)
        XCTAssertEqual(requestable.dataTaskFuncCheck.arguments?.allHTTPHeaderFields, givenHeaders)
    }
}
