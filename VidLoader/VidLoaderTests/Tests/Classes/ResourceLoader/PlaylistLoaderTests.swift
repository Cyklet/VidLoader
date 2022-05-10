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
    private var requestable: MockRequestable!
    private var playlistLoader: PlaylistLoader!

    override func setUp() {
        super.setUp()

        requestable = MockRequestable()
        playlistLoader = PlaylistLoader(requestable: requestable)
    }

    func test_NextResource_ArrayIsEmpty_ResultNil() {
        // GIVEN
        let expectedResource: (String, StreamResource)? = nil

        // WHEN
        let resultResource = playlistLoader.nextStreamResource

        // THEN
        XCTAssertTrue(expectedResource == resultResource)
    }

    func test_NextResource_ArrayIsNotEmpty_ResultExist() {
        // GIVEN
        let mockIdentifier = "ItemIdentifier"
        let data = Data.mock(string: mockIdentifier)
        let mockURL: URL = .mock(stringURL: "https://test.next.resource")
        let mockResponse: HTTPURLResponse = .mock(url: mockURL)
        let mockResource = StreamResource.mock(response: mockResponse, data: data)
        let expectedResult: (String, StreamResource)? = (mockIdentifier, mockResource)
        requestable.completionHandlerStub = (data, mockResponse, nil)
        requestable.dataTaskStub = .mock()
        let givenHeaders = ["User-Agent" : "Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1"]
        playlistLoader.load(identifier: mockIdentifier, at: mockURL, headers: givenHeaders) { _ in }

        // WHEN
        let finalResult = playlistLoader.nextStreamResource

        // THEN
        XCTAssertTrue(finalResult == expectedResult)
        XCTAssertEqual(requestable.dataTaskFuncCheck.arguments?.allHTTPHeaderFields, givenHeaders)
    }

    func test_LoadResource_FailedWithServerError_CompletionWithError() {
        // GIVEN
        let mockIdentifier = "FailedIdentifier"
        let expectedError: ResourceLoadingError = .urlScheme
        let mockDataTask: CustomDataTask = .mock()
        requestable.completionHandlerStub = (nil, nil, expectedError)
        requestable.dataTaskStub = mockDataTask
        var resultError: ResourceLoadingError?
        let givenHeaders: [String: String]? = nil

        // WHEN
        playlistLoader.load(identifier: mockIdentifier, at: .mock(), headers: givenHeaders) { response in
            switch response {
            case .success: return
            case .failure(let error): resultError = error as? ResourceLoadingError
            }
        }

        // THEN
        XCTAssertEqual(resultError, expectedError)
        XCTAssertTrue(mockDataTask.resumeFuncCheck.wasCalled())
        XCTAssertEqual(requestable.dataTaskFuncCheck.arguments?.allHTTPHeaderFields, givenHeaders)
    }
    
    func test_LoadResource_FailedWithNilError_CompletionWithUnknownError() {
        // GIVEN
        let mockIdentifier = "FailedIdentifier"
        let expectedError: DownloadError = .unknown
        let mockDataTask: CustomDataTask = .mock()
        requestable.completionHandlerStub = (nil, nil, nil)
        requestable.dataTaskStub = mockDataTask
        var resultError: DownloadError?
        let givenHeaders: [String: String]? = [:]

        // WHEN
        playlistLoader.load(identifier: mockIdentifier, at: .mock(), headers: givenHeaders) { response in
            switch response {
            case .success: return
            case .failure(let error): resultError = error as? DownloadError
            }
        }

        // THEN
        XCTAssertEqual(resultError, expectedError)
        XCTAssertTrue(mockDataTask.resumeFuncCheck.wasCalled())
        XCTAssertEqual(requestable.dataTaskFuncCheck.arguments?.allHTTPHeaderFields, nil)
    }

    func test_LoadResource_Success_CompletionWithSuccess() {
        // GIVEN
        let mockIdentifier = "SuccessIdentifier"
        let mockDataTask: CustomDataTask = .mock()
        requestable.completionHandlerStub = (.mock(), HTTPURLResponse.mock(), nil)
        requestable.dataTaskStub = mockDataTask
        var result = false

        // WHEN
        playlistLoader.load(identifier: mockIdentifier, at: .mock(), headers: nil) { response in
            switch response {
            case .success: result = true
            case .failure: return
            }
        }

        // THEN
        XCTAssertTrue(result)
        XCTAssertTrue(mockDataTask.resumeFuncCheck.wasCalled())
    }

    func test_Cancel_ItemDownloaded_NoNextItem() {
        // GIVEN
        let mockIdentifier = "ItemIdentifier"
        let mockDataTask: CustomDataTask = .mock()
        let data = Data.mock(string: mockIdentifier)
        let mockURL: URL = .mock(stringURL: "https://test.next.resource")
        let mockResponse: HTTPURLResponse = .mock(url: mockURL)
        requestable.completionHandlerStub = (data, mockResponse, nil)
        requestable.dataTaskStub = mockDataTask
        playlistLoader.load(identifier: mockIdentifier, at: mockURL, headers: nil) { _ in }

        // WHEN
        playlistLoader.cancel(identifier: mockIdentifier)
        let resultResource = playlistLoader.nextStreamResource

        // THEN
        XCTAssertNil(resultResource)
        XCTAssertTrue(mockDataTask.resumeFuncCheck.wasCalled())
        XCTAssertTrue(mockDataTask.cancelFuncCheck.wasCalled())
    }

    func test_Cancel_MultipleItemsDownloaded_NextItemExist() {
        // GIVEN
        let mockIdentifier1 = "ItemIdentifier"
        let mockIdentifier2 = "ItemIdentifier2"
        let data = Data.mock(string: mockIdentifier2)
        let mockURL: URL = .mock(stringURL: "https://test.next.resource")
        let mockResponse: HTTPURLResponse = .mock(url: mockURL)
        let mockResource = StreamResource.mock(response: mockResponse, data: data)
        let expectedResult: (String, StreamResource)? = (mockIdentifier2, mockResource)
        requestable.completionHandlerStub = (data, mockResponse, nil)
        requestable.dataTaskStub = .mock()
        playlistLoader.load(identifier: mockIdentifier1, at: mockURL, headers: nil) { _ in }
        playlistLoader.load(identifier: mockIdentifier2, at: mockURL, headers: nil) { _ in }

        // WHEN
        playlistLoader.cancel(identifier: mockIdentifier1)
        let finalResult = playlistLoader.nextStreamResource

        // THEN
        XCTAssert(finalResult == expectedResult)
    }
}
