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
    private var mockedRequastable: MockedRequestable!
    private var playlistLoader: PlaylistLoader!

    override func setUp() {
        super.setUp()

        mockedRequastable = MockedRequestable()
        playlistLoader = PlaylistLoader(requestable: mockedRequastable)
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
        let mockedIdentifier = "ItemIdentifier"
        let data = Data.mocked(string: mockedIdentifier)
        let mockedURL: URL = .mocked(stringURL: "https://test.next.resource")
        let mockedResponse: HTTPURLResponse = .mocked(url: mockedURL)
        let mockedResource = StreamResource.mocked(response: mockedResponse, data: data)
        let expectedResult: (String, StreamResource)? = (mockedIdentifier, mockedResource)
        mockedRequastable.mockedResponse = (data, mockedResponse, nil)
        mockedRequastable.mockedDataTask = .mocked()
        playlistLoader.load(identifier: mockedIdentifier, at: mockedURL) { _ in }

        // WHEN
        let finalResult = playlistLoader.nextStreamResource

        // THEN
        XCTAssertTrue(finalResult == expectedResult)
    }

    func testLoadResourceWhenFailedThenCompletionWithError() {
        // GIVEN
        let mockedIdentifier = "FailedIdentifier"
        let expectedError: MockedError = .test
        let mockedDataTask: CustomDataTask = .mocked()
        mockedRequastable.mockedResponse = (nil, nil, expectedError)
        mockedRequastable.mockedDataTask = mockedDataTask
        var resultError: MockedError?

        // WHEN
        playlistLoader.load(identifier: mockedIdentifier, at: .mocked()) { response in
            switch response {
            case .success: return
            case .failure(let error): resultError = error as? MockedError
            }
        }

        // THEN
        XCTAssertEqual(resultError, expectedError)
        XCTAssertEqual(mockedDataTask.resumeDidCall, true)
    }
    
    func testLoadResourceWhenFailedThenCompletionWithUnknownError() {
        // GIVEN
        let mockedIdentifier = "FailedIdentifier"
        let expectedError: DownloadError = .unknown
        let mockedDataTask: CustomDataTask = .mocked()
        mockedRequastable.mockedResponse = (nil, nil, nil)
        mockedRequastable.mockedDataTask = mockedDataTask
        var resultError: DownloadError?

        // WHEN
        playlistLoader.load(identifier: mockedIdentifier, at: .mocked()) { response in
            switch response {
            case .success: return
            case .failure(let error): resultError = error as? DownloadError
            }
        }

        // THEN
        XCTAssertEqual(resultError, expectedError)
        XCTAssertEqual(mockedDataTask.resumeDidCall, true)
    }

    func testLoadResourceWhenSuccessThenCompletionWithSuccess() {
        // GIVEN
        let mockedIdentifier = "SuccessIdentifier"
        let mockedDataTask: CustomDataTask = .mocked()
        mockedRequastable.mockedResponse = (.mocked(), HTTPURLResponse.mocked(), nil)
        mockedRequastable.mockedDataTask = mockedDataTask
        var result = false

        // WHEN
        playlistLoader.load(identifier: mockedIdentifier, at: .mocked()) { response in
            switch response {
            case .success: result = true
            case .failure: return
            }
        }

        // THEN
        XCTAssertTrue(result)
        XCTAssertEqual(mockedDataTask.resumeDidCall, true)
    }

    func testCancelWhenItemDownloadedThenNoNextItem() {
        // GIVEN
        let mockedIdentifier = "ItemIdentifier"
        let mockedDataTask: CustomDataTask = .mocked()
        let data = Data.mocked(string: mockedIdentifier)
        let mockedURL: URL = .mocked(stringURL: "https://test.next.resource")
        let mockedResponse: HTTPURLResponse = .mocked(url: mockedURL)
        mockedRequastable.mockedResponse = (data, mockedResponse, nil)
        mockedRequastable.mockedDataTask = mockedDataTask
        playlistLoader.load(identifier: mockedIdentifier, at: mockedURL) { _ in }

        // WHEN
        playlistLoader.cancel(identifier: mockedIdentifier)
        let resultResource = playlistLoader.nextStreamResource

        // THEN
        XCTAssertNil(resultResource)
        XCTAssertEqual(mockedDataTask.resumeDidCall, true)
        XCTAssertEqual(mockedDataTask.cancelDidCall, true)
    }

    func testCancelWhenMultipleItemsDownloadedThenNextItemExist() {
        // GIVEN
        let mockedIdentifier1 = "ItemIdentifier"
        let mockedIdentifier2 = "ItemIdentifier2"
        let data = Data.mocked(string: mockedIdentifier2)
        let mockedURL: URL = .mocked(stringURL: "https://test.next.resource")
        let mockedResponse: HTTPURLResponse = .mocked(url: mockedURL)
        let mockedResource = StreamResource.mocked(response: mockedResponse, data: data)
        let expectedResult: (String, StreamResource)? = (mockedIdentifier2, mockedResource)
        mockedRequastable.mockedResponse = (data, mockedResponse, nil)
        mockedRequastable.mockedDataTask = .mocked()
        playlistLoader.load(identifier: mockedIdentifier1, at: mockedURL) { _ in }
        playlistLoader.load(identifier: mockedIdentifier2, at: mockedURL) { _ in }

        // WHEN
        playlistLoader.cancel(identifier: mockedIdentifier1)
        let finalResult = playlistLoader.nextStreamResource

        // THEN
        XCTAssert(finalResult == expectedResult)
    }
}
