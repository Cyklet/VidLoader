//
//  DownloadStateTests.swift
//  VidLoaderTests
//
//  Created by Petre on 12/10/19.
//  Copyright © 2019 Petre. All rights reserved.
//

import XCTest
@testable import VidLoader

final class DownloadStateTests: XCTestCase {
    private var encoder: JSONEncoder!
    private var decoder: JSONDecoder!
    
    override func setUp() {
        super.setUp()
        
        encoder = JSONEncoder()
        decoder = JSONDecoder()
    }

    func test_EncodeDecode_Unknown_State() {
        // GIVEN
        let expectedState: DownloadState = .unknown
        
        // WHEN
        let data = try! encoder.encode(expectedState)
        let resultState = try? decoder.decode(DownloadState.self, from: data)
        
        // THEN
        XCTAssertEqual(expectedState, resultState)
    }
    
    func test_EncodeDecode_Prefetching_State() {
        // GIVEN
        let expectedState: DownloadState = .prefetching
        
        // WHEN
        let data = try! encoder.encode(expectedState)
        let resultState = try? decoder.decode(DownloadState.self, from: data)
        
        // THEN
        XCTAssertEqual(expectedState, resultState)
    }
    
    func test_EncodeDecode_Running_State() {
        // GIVEN
        let expectedState: DownloadState = .running(0.3)
        
        // WHEN
        let data = try! encoder.encode(expectedState)
        let resultState = try? decoder.decode(DownloadState.self, from: data)
        
        // THEN
        XCTAssertEqual(expectedState, resultState)
    }
    
    func test_EncodeDecode_Waiting_State() {
        // GIVEN
        let expectedState: DownloadState = .waiting
        
        // WHEN
        let data = try! encoder.encode(expectedState)
        let resultState = try? decoder.decode(DownloadState.self, from: data)
        
        // THEN
        XCTAssertEqual(expectedState, resultState)
    }
    
    func test_EncodeDecode_Suspended_State() {
        // GIVEN
        let expectedState: DownloadState = .noConnection(0.3)
        
        // WHEN
        let data = try! encoder.encode(expectedState)
        let resultState = try? decoder.decode(DownloadState.self, from: data)
        
        // THEN
        XCTAssertEqual(expectedState, resultState)
    }
    
    func test_EncodeDecode_Completed_State() {
        // GIVEN
        let expectedState: DownloadState = .completed
        
        // WHEN
        let data = try! encoder.encode(expectedState)
        let resultState = try? decoder.decode(DownloadState.self, from: data)
        
        // THEN
        XCTAssertEqual(expectedState, resultState)
    }
    
    func test_EncodeDecode_Canceled_State() {
        // GIVEN
        let expectedState: DownloadState = .canceled
        
        // WHEN
        let data = try! encoder.encode(expectedState)
        let resultState = try? decoder.decode(DownloadState.self, from: data)
        
        // THEN
        XCTAssertEqual(expectedState, resultState)
    }
    
    func test_EncodeDecode_Failed_State() {
        // GIVEN
        let expectedState: DownloadState = .failed(error: .custom(.init(error: DownloadError.taskNotCreated)))
        
        // WHEN
        let data = try! encoder.encode(expectedState)
        let resultState = try? decoder.decode(DownloadState.self, from: data)
        
        // THEN
        XCTAssertEqual(expectedState, resultState)
    }
    
    func test_EncodeDecode_KeyLoaded_State() {
        // GIVEN
        let expectedState: DownloadState = .keyLoaded
        
        // WHEN
        let data = try! encoder.encode(expectedState)
        let resultState = try? decoder.decode(DownloadState.self, from: data)
        
        // THEN
        XCTAssertEqual(expectedState, resultState)
    }
}
