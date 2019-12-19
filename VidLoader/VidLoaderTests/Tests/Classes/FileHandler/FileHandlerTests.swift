//
//  FileHandlerTests.swift
//  VidLoaderTests
//
//  Created by Petre on 12/6/19.
//  Copyright © 2019 Petre. All rights reserved.
//

import XCTest
@testable import VidLoader

final class FileHandlerTests: XCTestCase {
    private var fileManager: MockFileManager!
    private var executionQueue: MockVidLoaderExecutionQueue!
    private var fileHandler: FileHandleable!
    
    override func setUp() {
        super.setUp()
        
        fileManager = MockFileManager()
        executionQueue = MockVidLoaderExecutionQueue()
        fileHandler = FileHandler(fileManager: fileManager, executionQueue: executionQueue)
    }
    
    func test_DeleteItem_PathIsNil_RemoveWillNotBeCalled() {
        // GIVEN
        let item = ItemInformation.mock()
        
        // WHEN
        fileHandler.deleteContent(for: item)
        
        // THEN
        XCTAssertFalse(fileManager.removeItemFuncCheck.wasCalled(with: item.identifier))
        XCTAssertFalse(executionQueue.asyncFuncCheck.wasCalled())
    }
    
    func test_DeleteItem_PathExistAndNotReachable_RemoveWillNotBeCalled() {
        // GIVEN
        let item = ItemInformation.mock(path: "stream")
        
        // WHEN
        fileHandler.deleteContent(for: item)
        
        // THEN
        XCTAssertFalse(fileManager.removeItemFuncCheck.wasCalled(with: item.identifier))
        XCTAssertFalse(executionQueue.asyncFuncCheck.wasCalled())
    }
    
    func test_DeleteItem_PathExistAndReachable_RemoveWillBeCalled() {
        // GIVEN
        let enumerator = FileManager.default.enumerator(atPath: NSHomeDirectory())
        let fileRelativePath = enumerator?.nextObject() as? String
        let item = ItemInformation.mock(path: fileRelativePath)
        let expectedURL = fileRelativePath ?|> URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent
        
        // WHEN
        fileHandler.deleteContent(for: item)
        
        // THEN
        XCTAssertEqual(fileManager.removeItemFuncCheck.arguments, expectedURL?.path)
        XCTAssertTrue(executionQueue.asyncFuncCheck.wasCalled())
    }
}
