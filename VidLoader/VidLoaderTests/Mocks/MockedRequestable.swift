//
//  MockedRequestable.swift
//  VidLoaderTests
//
//  Created by Petre on 03.12.19.
//  Copyright © 2019 Petre. All rights reserved.
//

@testable import VidLoader

final class MockedRequestable: Requestable {

    var mockedResponse: (Data?, URLResponse?, Error?)
    var mockedDataTask: CustomDataTask!
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        completionHandler(mockedResponse.0, mockedResponse.1, mockedResponse.2)
        return mockedDataTask
    }
}
