//
//  ItemInformationTests.swift
//  VidLoaderTests
//
//  Created by Petre on 12/10/19.
//  Copyright © 2019 Petre. All rights reserved.
//

import XCTest
@testable import VidLoader

final class ItemInformationTests: XCTestCase {
    func test_ItemLocation_PathIsNil_LocationIsNil() {
        // GIVEN
        let givenItem: ItemInformation = .mock(path: nil)
        
        // WHEN
        let resultLocation = givenItem.location
        
        // THEN
        XCTAssertNil(resultLocation)
    }
    
    func test_ItemLocation_PathIsValid_LocationIsValid() {
        // GIVEN
        let givenPath = "video_123"
        let givenItem: ItemInformation = .mock(path: givenPath)
        let expectedLocation = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent(givenPath)
        
        // WHEN
        let resultLocation = givenItem.location
        
        // THEN
        XCTAssertEqual(expectedLocation, resultLocation)
    }
    
    func test_ItemIsReachable_LocationIsNil_ReachableIsFalse() {
        // GIVEN
        let givenItem: ItemInformation = .mock(path: nil)
        
        // WHEN
        let isReachable = givenItem.isReachable
        
        // THEN
        XCTAssertFalse(isReachable)
    }
    
    func test_ItemIsReachable_LocationExistAndNoReachable_ReachableIsFalse() {
        // GIVEN
        let givenPath = "video_123"
        let givenItem: ItemInformation = .mock(path: givenPath)
        
        // WHEN
        let isReachable = givenItem.isReachable
        
        // THEN
        XCTAssertFalse(isReachable)
    }
    
    func test_ItemIsReachable_LocationExistAndReachable_ReachableIsTrue() {
        // GIVEN
        let enumerator = FileManager.default.enumerator(atPath: NSHomeDirectory())
        let fileRelativePath = enumerator?.nextObject() as? String
        let givenItem = ItemInformation.mock(path: fileRelativePath)
        
        // WHEN
        let isReachable = givenItem.isReachable
        
        // THEN
        XCTAssertTrue(isReachable)
    }
    
    func test_ItemsStatesForProgress_ItemsAreDifferent_ResultSameAsExpectations() {
        // GIVEN
        let items: [ItemInformation] = [.mock(state: .unknown), .mock(state: .prefetching), .mock(state: .waiting),
                                        .mock(state: .running(0)), .mock(state: .suspended(0)), .mock(state: .completed),
                                        .mock(state: .canceled), .mock(state: .failed(error: .unknown)), .mock(state: .keyLoaded)]
        let expectedResult = [false, false, false, true, true, false, false, false, true]
        
        // WHEN
        let finalResult = items.map { $0.inProgress }
        
        // THEN
        XCTAssertEqual(expectedResult, finalResult)
    }
    
    func test_ItemsStatesForCancel_ItemsAreDifferent_ResultSameAsExpectations() {
        // GIVEN
        let items: [ItemInformation] = [.mock(state: .unknown), .mock(state: .prefetching), .mock(state: .waiting),
                                        .mock(state: .running(0)), .mock(state: .suspended(0)), .mock(state: .completed),
                                        .mock(state: .canceled), .mock(state: .failed(error: .unknown)), .mock(state: .keyLoaded)]
        let expectedResult = [false, false, false, false, false, false, true, false, false]
        
        // WHEN
        let finalResult = items.map { $0.isCancelled }
        
        // THEN
        XCTAssertEqual(expectedResult, finalResult)
    }
    
    func test_StateLens_LensIsSettedAndRequested_ResultsCorrespondWithExpectations() {
        // GIVEN
        let givenItem: ItemInformation = .mock(state: .unknown)
        let expectedState: DownloadState = .prefetching
        let expectedItem: ItemInformation = .mock(state: expectedState)
    
        // WHEN
        let resultItem = givenItem |> ItemInformation._state .~ expectedState
        let resultState = ItemInformation._state.get(resultItem)
        
        // THEN
        XCTAssertEqual(expectedItem, resultItem)
        XCTAssertEqual(expectedState, resultState)
    }
    
    func test_PathLens_LensIsSettedAndRequested_ResultsCorrespondWithExpectations() {
        // GIVEN
        let givenItem: ItemInformation = .mock(path: "natural_path")
        let expectedPath = "lens_path"
        let expectedItem: ItemInformation = .mock(path: expectedPath)
    
        // WHEN
        let resultItem = givenItem |> ItemInformation._path .~ expectedPath
        let resultPath = ItemInformation._path.get(resultItem)
        
        // THEN
        XCTAssertEqual(expectedItem, resultItem)
        XCTAssertEqual(expectedPath, resultPath)
    }
    
    func test_ProgressLens_LensIsSettedAndRequested_ResultsCorrespondWithExpectations() {
        // GIVEN
        let givenItem: ItemInformation = .mock(progress: 0)
        let expectedProgress = 0.2
        let expectedItem: ItemInformation = .mock(progress: expectedProgress)
    
        // WHEN
        let resultItem = givenItem |> ItemInformation._progress .~ expectedProgress
        let resultProgress = ItemInformation._progress.get(resultItem)
        
        // THEN
        XCTAssertEqual(expectedItem, resultItem)
        XCTAssertEqual(expectedProgress, resultProgress)
    }
    
    func test_DownloadedBytesLens_LensIsSettedAndRequested_ResultsCorrespondWithExpectations() {
        // GIVEN
        let givenItem: ItemInformation = .mock(downloadedBytes: 0)
        let expectedDownloadedBytes = 123141
        let expectedItem: ItemInformation = .mock(downloadedBytes: expectedDownloadedBytes)
    
        // WHEN
        let resultItem = givenItem |> ItemInformation._downloadedBytes .~ expectedDownloadedBytes
        let resultDownloadedBytes = ItemInformation._downloadedBytes.get(resultItem)
        
        // THEN
        XCTAssertEqual(expectedItem, resultItem)
        XCTAssertEqual(expectedDownloadedBytes, resultDownloadedBytes)
    }
}
