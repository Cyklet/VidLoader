//
//  SchemeHandlerTests.swift
//  VidLoaderTests
//
//  Created by Petre on 12/6/19.
//  Copyright © 2019 Petre. All rights reserved.
//
import XCTest
import AVFoundation
@testable import VidLoader

final class SchemeHandlerTests: XCTestCase {
    private var schemeHandler: SchemeHandler!
    
    override func setUp() {
        super.setUp()
        
        schemeHandler = SchemeHandler()
    }
    
    func test_ExtractKeyFromURL_LinkHasKeyScheme_ResultIsKeyData() {
        // GIVEN
        let base64Key = "YWdlbnRfMDA3"
        let url = URL.mock(stringURL: "\(SchemeType.key.rawValue):\(base64Key)")
        let expectedKeyData =  Data(base64Encoded: base64Key)
        
        // WHEN
        let resultKeyData = schemeHandler.persistentKey(from: url)
        
        // THEN
        XCTAssertEqual(expectedKeyData, resultKeyData)
    }
    
    func test_ExtractKeyFromURL_LinkHasWrongKey_ResultIsNil() {
        // GIVEN
        let url = URL.mock(stringURL: "\(SchemeType.original.rawValue):a_key_here")
        
        // WHEN
        let resultKeyData = schemeHandler.persistentKey(from: url)
        
        // THEN
        XCTAssertNil(resultKeyData)
    }
    
    func test_ExtractKeyFromURL_KeyIsWrongEncrypted_ResultIsNil() {
        // GIVEN
        let stringKey = "agent_007"
        let url = URL.mock(stringURL: "\(SchemeType.key.rawValue):\(stringKey)")
        
        // WHEN
        let resultKeyData = schemeHandler.persistentKey(from: url)
        
        // THEN
        XCTAssertNil(resultKeyData)
    }
    
    func test_GenerateURLAsset_LinkIsNil_AssetIsNil() {
        // GIVEN
        let url: URL? = nil
        let expectedResult: Result<AVURLAsset, ResourceLoadingError> = .failure(.urlScheme)
        
        // WHEN
        let finalResult = schemeHandler.urlAsset(with: url, data: .init())
        
        // THEN
        XCTAssertEqual(expectedResult, finalResult)
    }
    
    func test_GenerateURLAsset_LinkIsVaild_AssetURLHasMasterScheme() {
        // GIVEN
        let expectedScheme = SchemeType.master.rawValue
        let url = URL.mock(stringURL: "\(SchemeType.original.rawValue)://url_to_m3u8.co.co")
        let givenData = Data.mock(string: "#WRONG-E-X-T-I-N-F")
        
        // WHEN
        let resultScheme = try? schemeHandler.urlAsset(with: url, data: givenData).get().url.scheme
        
        // THEN
        XCTAssertEqual(expectedScheme, resultScheme)
    }
    
    func test_GenerateURLAsset_LinkIsVaild_AssetURLHasVariantScheme() {
        // GIVEN
        let expectedScheme = SchemeType.variant.rawValue
        let url = URL.mock(stringURL: "\(SchemeType.original.rawValue)://url_to_m3u8.co.co")
        let givenData = Data.mock(string: "#EXTINF")
        
        // WHEN
        let resultScheme = try? schemeHandler.urlAsset(with: url, data: givenData).get().url.scheme
        
        // THEN
        XCTAssertEqual(expectedScheme, resultScheme)
    }

    func test_CheckSchemeType_URLContainsHttps_OriginalSchemeTypeIsReturned() {
        // GIVEN
        let expectedScheme = SchemeType.original
        let url = URL.mock(stringURL: "https://url_to_m3u8.co.co")
        
        // WHEN
        let resultScheme = schemeHandler.schemeType(from: url)
        
        // THEN
        XCTAssertEqual(expectedScheme, resultScheme)
    }
    
    func test_CheckSchemeType_URLContainsVariantName_VariantSchemeTypeIsReturned() {
        // GIVEN
        let expectedScheme = SchemeType.variant
        let url = URL.mock(stringURL: "vidloader-variant://url_to_m3u8.co.co")
        
        // WHEN
        let resultScheme = schemeHandler.schemeType(from: url)
        
        // THEN
        XCTAssertEqual(expectedScheme, resultScheme)
    }
    
    func test_CheckSchemeType_URLContainsMasterName_MasterSchemeTypeIsReturned() {
        // GIVEN
        let expectedScheme = SchemeType.master
        let url = URL.mock(stringURL: "vidloader-master://url_to_m3u8.co.co")
        
        // WHEN
        let resultScheme = schemeHandler.schemeType(from: url)
        
        // THEN
        XCTAssertEqual(expectedScheme, resultScheme)
    }
    
    func test_CheckSchemeType_URLContainsKeyName_KeySchemeTypeIsReturned() {
        // GIVEN
        let expectedScheme = SchemeType.key
        let url = URL.mock(stringURL: "vidloader-encryption-key://url_to_m3u8.co.co")
        
        // WHEN
        let resultScheme = schemeHandler.schemeType(from: url)
        
        // THEN
        XCTAssertEqual(expectedScheme, resultScheme)
    }
    
    func test_CheckSchemeType_URLContainsUnkownName_NilSchemeTypeIsReturned() {
        // GIVEN
        let url = URL.mock(stringURL: "new_unknown_scheme://url_to_m3u8.co.co")
        
        // WHEN
        let resultScheme = schemeHandler.schemeType(from: url)
        
        // THEN
        XCTAssertNil(resultScheme)
    }
}
