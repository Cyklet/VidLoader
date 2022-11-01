//
//  StreamResourceTests.swift
//  VidLoaderTests
//
//  Created by Petre on 6/19/20.
//  Copyright © 2020 Petre. All rights reserved.
//

import XCTest
@testable import VidLoader

final class StreamResourceTests: XCTestCase {
    
    func test_GenerateStreamResource_WithoutChunkKey_FileTypeMaster() {
        // GIVEN
        let givenData = "no_chunk_key_inside".data!
        let givenResponse = HTTPURLResponse.mock()
        
        // WHEN
        let resultStream = StreamResource(response: givenResponse, data: givenData)
        
        // THEN
        XCTAssertEqual(givenData, resultStream.data)
        XCTAssertEqual(givenResponse, resultStream.response)
    }
    
    func test_GenerateStreamResource_WithChunkKey_FileTypeVariant() {
        // GIVEN
        let variantChunkKey = "#EXTINF"
        let givenData = "chunk_key_inside\(variantChunkKey)".data!
        let givenResponse = HTTPURLResponse.mock()
        
        // WHEN
        let resultStream = StreamResource(response: givenResponse, data: givenData)
        
        // THEN
        XCTAssertEqual(givenData, resultStream.data)
        XCTAssertEqual(givenResponse, resultStream.response)
    }
}
