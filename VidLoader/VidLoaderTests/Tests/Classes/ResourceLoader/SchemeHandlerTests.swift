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
        let url = URL.mocked(stringURL: "\(SchemeType.key.rawValue):\(base64Key)")
        let expectedKeyData =  Data(base64Encoded: base64Key)
        
        // WHEN
        let resultKeyData = schemeHandler.persistentKey(from: url)
        
        // THEN
        XCTAssertEqual(expectedKeyData, resultKeyData)
    }
    
    func test_ExtractKeyFromURL_LinkHasWrongKey_ResultIsNil() {
        // GIVEN
        let url = URL.mocked(stringURL: "\(SchemeType.original.rawValue):a_key_here")
        
        // WHEN
        let resultKeyData = schemeHandler.persistentKey(from: url)
        
        // THEN
        XCTAssertNil(resultKeyData)
    }
    
    func test_ExtractKeyFromURL_KeyIsWrongEncrypted_ResultIsNil() {
        // GIVEN
        let stringKey = "agent_007"
        let url = URL.mocked(stringURL: "\(SchemeType.key.rawValue):\(stringKey)")
        
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
        let finalResult = schemeHandler.urlAsset(with: url)
        
        // THEN
        XCTAssertEqual(expectedResult, finalResult)
    }
    
    func test_GenerateURLAsset_LinkIsVaild_AssetURLHasNewScheme() {
        // GIVEN
        let expectedScheme = SchemeType.custom.rawValue
        let url = URL.mocked(stringURL: "\(SchemeType.original.rawValue)://url_to_m3u8.co.co")
        
        // WHEN
        let resultScheme = try? schemeHandler.urlAsset(with: url).get().url.scheme
        
        // THEN
        XCTAssertEqual(expectedScheme, resultScheme)
    }
}
