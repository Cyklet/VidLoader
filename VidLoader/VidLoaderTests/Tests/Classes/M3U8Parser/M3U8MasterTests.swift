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
    private var executionQueue: MockVidLoaderExecutionQueue!
    private var time: DispatchTime!
    
    override func setUp() {
        super.setUp()
        
        executionQueue = .init()
        let newTime = DispatchTime.now()
        time = newTime
        let timeCall: () -> DispatchTime = { newTime }
        parser = M3U8Master(executionQueue: executionQueue, time: timeCall)
    }
    
    func test_AdjustMasterScheme_OriginalSchemeExist_SchemeIsReplaced() {
        // GIVEN
        let path = "random_path"
        let givenString = "\(SchemeType.original.rawValue)://\(path)"
        let expectedResult: Result<Data, M3U8Error> = .success(.mock(string: "\(SchemeType.custom.rawValue)://\(path)"))
        let finalResultFuncCheck = FuncCheck<Result<Data, M3U8Error>>()
        let expectedDelay = time + 0.5
        
        // WHEN
        parser.adjust(data: .mock(string: givenString),
                      completion: { finalResultFuncCheck.call($0) })
        
        // THEN
        XCTAssertTrue(finalResultFuncCheck.wasCalled(with: expectedResult))
        XCTAssertTrue(executionQueue.asyncAfterFuncCheck.wasCalled(with: expectedDelay))
    }
    
    func test_AdjustMasterScheme_OriginalSchemeNotExist_SchemeIsNotReplaced() {
        // GIVEN
        let givenString = "wrong_scheme://random.path.co"
        let expectedResult: Result<Data, M3U8Error> = .success(.mock(string: givenString))
        let finalResultFuncCheck = FuncCheck<Result<Data, M3U8Error>>()
        let expectedDelay = time + 0.5
        
        // WHEN
        parser.adjust(data: .mock(string: givenString),
                      completion: { finalResultFuncCheck.call($0) })
        
        // THEN
        XCTAssertTrue(finalResultFuncCheck.wasCalled(with: expectedResult))
        XCTAssertTrue(executionQueue.asyncAfterFuncCheck.wasCalled(with: expectedDelay))
    }
}
