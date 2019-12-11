//
//  PlaylistLoaderTests.swift
//  VidLoaderTests
//
//  Created by Petre on 03.12.19.
//  Copyright © 2019 Petre. All rights reserved.
//
import XCTest
@testable import VidLoader

final class PlaylistLoaderTests: XCTestCase {
    private var requastable: MockRequestable!
    private var playlistLoader: PlaylistLoader!

    override func setUp() {
        super.setUp()

        requastable = MockRequestable()
        playlistLoader = PlaylistLoader(requestable: requastable)
    }

    func testNextResourceWhenArrayIsEmptyThenResultNil() {
        // GIVEN
        let expectedResource: (String, StreamResource)? = nil

        // WHEN
        let resultResource = playlistLoader.nextStreamResource

        // THEN
        XCTAssertTrue(expectedResource == resultResource)
    }

    func testNextResourceWhenArrayIsNotEmptyThenResultExist() {
        // GIVEN
        let mockIdentifier = "ItemIdentifier"
        let data = Data.mock(string: mockIdentifier)
        let mockURL: URL = .mock(stringURL: "https://test.next.resource")
        let mockResponse: HTTPURLResponse = .mock(url: mockURL)
        let mockResource = StreamResource.mock(response: mockResponse, data: data)
        let expectedResult: (String, StreamResource)? = (mockIdentifier, mockResource)
        requastable.completionHandlerStub = (data, mockResponse, nil)
        requastable.dataTaskStub = .mock()
        playlistLoader.load(identifier: mockIdentifier, at: mockURL) { _ in }

        // WHEN
        let finalResult = playlistLoader.nextStreamResource

        // THEN
        XCTAssertTrue(finalResult == expectedResult)
    }

    func testLoadResourceWhenFailedThenCompletionWithError() {
        // GIVEN
        let mockIdentifier = "FailedIdentifier"
        let expectedError: ResourceLoadingError = .unknown
        let mockDataTask: CustomDataTask = .mock()
        requastable.completionHandlerStub = (nil, nil, expectedError)
        requastable.dataTaskStub = mockDataTask
        var resultError: ResourceLoadingError?

        // WHEN
        playlistLoader.load(identifier: mockIdentifier, at: .mock()) { response in
            switch response {
            case .success: return
            case .failure(let error): resultError = error as? ResourceLoadingError
            }
        }

        // THEN
        XCTAssertEqual(resultError, expectedError)
        XCTAssertTrue(mockDataTask.resumeFuncCheck.wasCalled())
    }
    
    func testLoadResourceWhenFailedThenCompletionWithUnknownError() {
        // GIVEN
        let mockIdentifier = "FailedIdentifier"
        let expectedError: DownloadError = .unknown
        let mockDataTask: CustomDataTask = .mock()
        requastable.completionHandlerStub = (nil, nil, nil)
        requastable.dataTaskStub = mockDataTask
        var resultError: DownloadError?

        // WHEN
        playlistLoader.load(identifier: mockIdentifier, at: .mock()) { response in
            switch response {
            case .success: return
            case .failure(let error): resultError = error as? DownloadError
            }
        }

        // THEN
        XCTAssertEqual(resultError, expectedError)
        XCTAssertTrue(mockDataTask.resumeFuncCheck.wasCalled())
    }

    func testLoadResourceWhenSuccessThenCompletionWithSuccess() {
        // GIVEN
        let mockIdentifier = "SuccessIdentifier"
        let mockDataTask: CustomDataTask = .mock()
        requastable.completionHandlerStub = (.mock(), HTTPURLResponse.mock(), nil)
        requastable.dataTaskStub = mockDataTask
        var result = false

        // WHEN
        playlistLoader.load(identifier: mockIdentifier, at: .mock()) { response in
            switch response {
            case .success: result = true
            case .failure: return
            }
        }

        // THEN
        XCTAssertTrue(result)
        XCTAssertTrue(mockDataTask.resumeFuncCheck.wasCalled())
    }

    func testCancelWhenItemDownloadedThenNoNextItem() {
        // GIVEN
        let mockIdentifier = "ItemIdentifier"
        let mockDataTask: CustomDataTask = .mock()
        let data = Data.mock(string: mockIdentifier)
        let mockURL: URL = .mock(stringURL: "https://test.next.resource")
        let mockResponse: HTTPURLResponse = .mock(url: mockURL)
        requastable.completionHandlerStub = (data, mockResponse, nil)
        requastable.dataTaskStub = mockDataTask
        playlistLoader.load(identifier: mockIdentifier, at: mockURL) { _ in }

        // WHEN
        playlistLoader.cancel(identifier: mockIdentifier)
        let resultResource = playlistLoader.nextStreamResource

        // THEN
        XCTAssertNil(resultResource)
        XCTAssertTrue(mockDataTask.resumeFuncCheck.wasCalled())
        XCTAssertTrue(mockDataTask.cancelFuncCheck.wasCalled())
    }

    func testCancelWhenMultipleItemsDownloadedThenNextItemExist() {
        // GIVEN
        let mockIdentifier1 = "ItemIdentifier"
        let mockIdentifier2 = "ItemIdentifier2"
        let data = Data.mock(string: mockIdentifier2)
        let mockURL: URL = .mock(stringURL: "https://test.next.resource")
        let mockResponse: HTTPURLResponse = .mock(url: mockURL)
        let mockResource = StreamResource.mock(response: mockResponse, data: data)
        let expectedResult: (String, StreamResource)? = (mockIdentifier2, mockResource)
        requastable.completionHandlerStub = (data, mockResponse, nil)
        requastable.dataTaskStub = .mock()
        playlistLoader.load(identifier: mockIdentifier1, at: mockURL) { _ in }
        playlistLoader.load(identifier: mockIdentifier2, at: mockURL) { _ in }

        // WHEN
        playlistLoader.cancel(identifier: mockIdentifier1)
        let finalResult = playlistLoader.nextStreamResource

        // THEN
        XCTAssert(finalResult == expectedResult)
    }
}
