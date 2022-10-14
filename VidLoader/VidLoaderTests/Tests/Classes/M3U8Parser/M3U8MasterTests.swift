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
    
    func test_AdjustMasterScheme_RelativeURLS_BaseURLAttached() {
        // GIVEN
        let urlPath = "parser.m3u8.test"
        let givenBaseURL = URL.mock(stringURL: "https://\(urlPath)")
        let expectedURLString = "\(SchemeType.variant.rawValue)://\(urlPath)/"
        let master = """
#EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID="subs",NAME="English",DEFAULT=YES,AUTOSELECT=YES,FORCED=NO,LANGUAGE="en",URI="cc/en/en.m3u8"
#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="english_64",LANGUAGE="en",NAME="English",AUTOSELECT=YES,DEFAULT=YES,URI="audio_english_64/prog_index.m3u8"

#EXT-X-STREAM-INF:BANDWIDTH=446094,AVERAGE-BANDWIDTH=187133,VIDEO-RANGE=SDR,CODECS="avc1.4d401f,mp4a.40.5",RESOLUTION=960x540,FRAME-RATE=29.970,AUDIO="english_64",SUBTITLES="subs"
avc_540p_2000/prog_index.m3u8
#EXT-X-I-FRAME-STREAM-INF:BANDWIDTH=167915,AVERAGE-BANDWIDTH=49610,CODECS="avc1.4d401f",RESOLUTION=960x540,URI="avc_540p_2000/iframe_index.m3u8"
"""
        let expectedMaster = """
#EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID="subs",NAME="English",DEFAULT=YES,AUTOSELECT=YES,FORCED=NO,LANGUAGE="en",URI="\(expectedURLString)cc/en/en.m3u8"
#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="english_64",LANGUAGE="en",NAME="English",AUTOSELECT=YES,DEFAULT=YES,URI="\(expectedURLString)audio_english_64/prog_index.m3u8"

#EXT-X-STREAM-INF:BANDWIDTH=446094,AVERAGE-BANDWIDTH=187133,VIDEO-RANGE=SDR,CODECS="avc1.4d401f,mp4a.40.5",RESOLUTION=960x540,FRAME-RATE=29.970,AUDIO="english_64",SUBTITLES="subs"
\(expectedURLString)avc_540p_2000/prog_index.m3u8
#EXT-X-I-FRAME-STREAM-INF:BANDWIDTH=167915,AVERAGE-BANDWIDTH=49610,CODECS="avc1.4d401f",RESOLUTION=960x540,URI="\(expectedURLString)avc_540p_2000/iframe_index.m3u8"
"""
        let expectedResult: Result<Data, M3U8Error> = .success(.mock(string: expectedMaster))
        
        // WHEN
        let result = parser.adjust(data: .mock(string: master), baseURL: givenBaseURL)
        
        // THEN
        XCTAssertEqual(expectedResult, result)
    }
    
    func test_AdjustMasterScheme_AbsoluteURLs_SchemesAreReplaced() {
        // GIVEN
        let urlPath = "parser.m3u8.test"
        let givenBaseURL = URL.mock(stringURL: "https://\(urlPath)")
        let master = """
#EXTM3U

#EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID="subs",NAME="English",DEFAULT=YES,AUTOSELECT=YES,FORCED=NO,LANGUAGE="en",URI="https://avid.test.co/unknown/videos/en.m3u8"
#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=2200000
https://avid.test.co/unknown/videos/best_26075.m3u8
"""
        let expectedMaster = """
#EXTM3U

#EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID="subs",NAME="English",DEFAULT=YES,AUTOSELECT=YES,FORCED=NO,LANGUAGE="en",URI="\(SchemeType.variant.rawValue)://avid.test.co/unknown/videos/en.m3u8"
#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=2200000
\(SchemeType.variant.rawValue)://avid.test.co/unknown/videos/best_26075.m3u8
"""
        let expectedResult: Result<Data, M3U8Error> = .success(.mock(string: expectedMaster))
        
        // WHEN
        let result = parser.adjust(data: .mock(string: master), baseURL: givenBaseURL)
        
        // THEN
        XCTAssertEqual(expectedResult, result)
    }
    
    func test_AdjustMasterScheme_MixedURLs_SchemesAreReplacedAndBaseURLAttached() {
        // GIVEN
        let urlPath = "parser.m3u8.test"
        let givenBaseURL = URL.mock(stringURL: "https://\(urlPath)")
        let expectedURLString = "\(SchemeType.variant.rawValue)://\(urlPath)/"
        let master = """
#EXTM3U
#EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID="subs",NAME="English",DEFAULT=YES,AUTOSELECT=YES,FORCED=NO,LANGUAGE="en",URI="https://avid.test.co/unknown/videos/en.m3u8"

#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=2200000
https://avid.test.co/unknown/videos/best_26075.m3u8

#EXT-X-STREAM-INF:BANDWIDTH=446094,AVERAGE-BANDWIDTH=187133,VIDEO-RANGE=SDR,CODECS="avc1.4d401f,mp4a.40.5",RESOLUTION=960x540,FRAME-RATE=29.970,AUDIO="english_64",SUBTITLES="subs"
avc_540p_2000/prog_index.m3u8
#EXT-X-I-FRAME-STREAM-INF:BANDWIDTH=167915,AVERAGE-BANDWIDTH=49610,CODECS="avc1.4d401f",RESOLUTION=960x540,URI="avc_540p_2000/iframe_index.m3u8"
"""
        let expectedMaster = """
#EXTM3U
#EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID="subs",NAME="English",DEFAULT=YES,AUTOSELECT=YES,FORCED=NO,LANGUAGE="en",URI="\(SchemeType.variant.rawValue)://avid.test.co/unknown/videos/en.m3u8"

#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=2200000
\(SchemeType.variant.rawValue)://avid.test.co/unknown/videos/best_26075.m3u8

#EXT-X-STREAM-INF:BANDWIDTH=446094,AVERAGE-BANDWIDTH=187133,VIDEO-RANGE=SDR,CODECS="avc1.4d401f,mp4a.40.5",RESOLUTION=960x540,FRAME-RATE=29.970,AUDIO="english_64",SUBTITLES="subs"
\(expectedURLString)avc_540p_2000/prog_index.m3u8
#EXT-X-I-FRAME-STREAM-INF:BANDWIDTH=167915,AVERAGE-BANDWIDTH=49610,CODECS="avc1.4d401f",RESOLUTION=960x540,URI="\(expectedURLString)avc_540p_2000/iframe_index.m3u8"
"""
        let expectedResult: Result<Data, M3U8Error> = .success(.mock(string: expectedMaster))
        
        // WHEN
        let result = parser.adjust(data: .mock(string: master), baseURL: givenBaseURL)
        
        // THEN
        XCTAssertEqual(expectedResult, result)
    }
    
    func test_AdjustMasterScheme_OriginalSchemeNotExist_SchemeIsNotReplaced() {
        // GIVEN
        let givenString = "wrong_scheme://random.path.co"
        let expectedResult: Result<Data, M3U8Error> = .success(.mock(string: givenString))
        
        // WHEN
        let result = parser.adjust(data: .mock(string: givenString), baseURL: URL.mock())
        
        // THEN
        XCTAssertEqual(expectedResult, result)
    }
}
