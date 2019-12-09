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
        mockedRequastable.completionHandlerStub = (data, mockedResponse, nil)
        mockedRequastable.dataTaskStub = .mocked()
        playlistLoader.load(identifier: mockedIdentifier, at: mockedURL) { _ in }

        // WHEN
        let finalResult = playlistLoader.nextStreamResource

        // THEN
        XCTAssertTrue(finalResult == expectedResult)
    }

    func testLoadResourceWhenFailedThenCompletionWithError() {
        // GIVEN
        let mockedIdentifier = "FailedIdentifier"
        let expectedError: ResourceLoadingError = .unknown
        let mockedDataTask: CustomDataTask = .mocked()
        mockedRequastable.completionHandlerStub = (nil, nil, expectedError)
        mockedRequastable.dataTaskStub = mockedDataTask
        var resultError: ResourceLoadingError?

        // WHEN
        playlistLoader.load(identifier: mockedIdentifier, at: .mocked()) { response in
            switch response {
            case .success: return
            case .failure(let error): resultError = error as? ResourceLoadingError
            }
        }

        // THEN
        XCTAssertEqual(resultError, expectedError)
        XCTAssertTrue(mockedDataTask.resumeFunCheck.wasCalled())
    }
    
    func testLoadResourceWhenFailedThenCompletionWithUnknownError() {
        // GIVEN
        let mockedIdentifier = "FailedIdentifier"
        let expectedError: DownloadError = .unknown
        let mockedDataTask: CustomDataTask = .mocked()
        mockedRequastable.completionHandlerStub = (nil, nil, nil)
        mockedRequastable.dataTaskStub = mockedDataTask
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
        XCTAssertTrue(mockedDataTask.resumeFunCheck.wasCalled())
    }

    func testLoadResourceWhenSuccessThenCompletionWithSuccess() {
        // GIVEN
        let mockedIdentifier = "SuccessIdentifier"
        let mockedDataTask: CustomDataTask = .mocked()
        mockedRequastable.completionHandlerStub = (.mocked(), HTTPURLResponse.mocked(), nil)
        mockedRequastable.dataTaskStub = mockedDataTask
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
        XCTAssertTrue(mockedDataTask.resumeFunCheck.wasCalled())
    }

    func testCancelWhenItemDownloadedThenNoNextItem() {
        // GIVEN
        let mockedIdentifier = "ItemIdentifier"
        let mockedDataTask: CustomDataTask = .mocked()
        let data = Data.mocked(string: mockedIdentifier)
        let mockedURL: URL = .mocked(stringURL: "https://test.next.resource")
        let mockedResponse: HTTPURLResponse = .mocked(url: mockedURL)
        mockedRequastable.completionHandlerStub = (data, mockedResponse, nil)
        mockedRequastable.dataTaskStub = mockedDataTask
        playlistLoader.load(identifier: mockedIdentifier, at: mockedURL) { _ in }

        // WHEN
        playlistLoader.cancel(identifier: mockedIdentifier)
        let resultResource = playlistLoader.nextStreamResource

        // THEN
        XCTAssertNil(resultResource)
        XCTAssertTrue(mockedDataTask.resumeFunCheck.wasCalled())
        XCTAssertTrue(mockedDataTask.cancelFunCheck.wasCalled())
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
        mockedRequastable.completionHandlerStub = (data, mockedResponse, nil)
        mockedRequastable.dataTaskStub = .mocked()
        playlistLoader.load(identifier: mockedIdentifier1, at: mockedURL) { _ in }
        playlistLoader.load(identifier: mockedIdentifier2, at: mockedURL) { _ in }

        // WHEN
        playlistLoader.cancel(identifier: mockedIdentifier1)
        let finalResult = playlistLoader.nextStreamResource

        // THEN
        XCTAssert(finalResult == expectedResult)
    }
}
