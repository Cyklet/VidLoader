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
    
    func testExtractKeyFromURLWhenLinkHasKeySchemeThenResultIsKeyData() {
        // GIVEN
        let base64Key = "YWdlbnRfMDA3"
        let url = URL.mocked(stringURL: "\(schemeHandler.keyScheme):\(base64Key)")
        let expectedKeyData =  Data(base64Encoded: base64Key)
        
        // WHEN
        let resultKeyData = schemeHandler.persistentKey(from: url)
        
        // THEN
        XCTAssertEqual(expectedKeyData, resultKeyData)
    }
    
    func testExtractKeyFromURLWhenLinkHasWrongKeyThenResultIsNil() {
        // GIVEN
        let url = URL.mocked(stringURL: "\(schemeHandler.validScheme):a_key_here")
        
        // WHEN
        let resultKeyData = schemeHandler.persistentKey(from: url)
        
        // THEN
        XCTAssertNil(resultKeyData)
    }
    
    func testExtractKeyFromURLWhenKeyIsWrongEncryptedThenResultIsNil() {
        // GIVEN
        let stringKey = "agent_007"
        let url = URL.mocked(stringURL: "\(schemeHandler.keyScheme):\(stringKey)")
        
        // WHEN
        let resultKeyData = schemeHandler.persistentKey(from: url)
        
        // THEN
        XCTAssertNil(resultKeyData)
    }
    
    func testGenerateURLAssetWhenLinkIsNilThenAssetIsNil() {
        // GIVEN
        let url: URL? = nil
        let expectedResult: Result<AVURLAsset, ResourceLoadingError> = .failure(.urlScheme)
        
        // WHEN
        let finalResult = schemeHandler.urlAsset(with: url)
        
        // THEN
        XCTAssertEqual(expectedResult, finalResult)
    }
    
    func testGenerateURLAssetWhenLinkIsVaildThenAssetURLHasNewScheme() {
        // GIVEN
        let expectedScheme = schemeHandler.newScheme
        let url = URL.mocked(stringURL: "\(schemeHandler.validScheme)://url_to_m3u8.co.co")
        
        // WHEN
        let resultScheme = try? schemeHandler.urlAsset(with: url).get().url.scheme
        
        // THEN
        XCTAssertEqual(expectedScheme, resultScheme)
    }
}
