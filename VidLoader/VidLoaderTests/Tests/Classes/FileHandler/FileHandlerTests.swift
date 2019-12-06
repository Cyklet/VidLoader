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
    private var fileManager: MockedFileManager!
    private var executionQueue: MockedVidLoaderExecutionQueue!
    private var fileHandler: FileHandleable!
    
    override func setUp() {
        super.setUp()
        
        fileManager = MockedFileManager()
        executionQueue = MockedVidLoaderExecutionQueue()
        fileHandler = FileHandler(fileManager: fileManager, executionQueue: executionQueue)
    }
    
    func testDeleteItemWhenPathIsNilThenRemoveWillNotBeCalled() {
        // GIVEN
        let item = ItemInformation.mocked()
        
        // WHEN
        fileHandler.deleteContent(for: item)
        
        // THEN
        XCTAssertNil(fileManager.removeItemDidCall)
        XCTAssertNil(executionQueue.asyncDidCall)
    }
    
    func testDeleteItemWhenPathExistAndNotReachableThenRemoveWillNotBeCalled() {
        // GIVEN
        let item = ItemInformation.mocked(path: "stream")
        
        // WHEN
        fileHandler.deleteContent(for: item)
        
        // THEN
        XCTAssertNil(fileManager.removeItemDidCall)
        XCTAssertNil(executionQueue.asyncDidCall)
    }
    
    func testDeleteItemWhenPathExistAndReachableThenRemoveWillBeCalled() {
        // GIVEN
        let enumerator = FileManager.default.enumerator(atPath: NSHomeDirectory())
        let fileRelativePath = enumerator?.nextObject() as? String
        let item = ItemInformation.mocked(path: fileRelativePath)
        
        // WHEN
        fileHandler.deleteContent(for: item)
        
        // THEN
        XCTAssertEqual(fileManager.removeItemDidCall, true)
        XCTAssertEqual(executionQueue.asyncDidCall, true)
    }
}
