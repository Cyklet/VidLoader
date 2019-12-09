//
//  MockedRequestable.swift
//  VidLoaderTests
//
//  Created by Petre on 03.12.19.
//  Copyright © 2019 Petre. All rights reserved.
//

@testable import VidLoader

final class MockedRequestable: Requestable {

    var completionHandlerStub: (Data?, URLResponse?, Error?)
    var dataTaskStub: CustomDataTask!
    var dataTaskFunCheck = FuncCheck<URLRequest>()
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        dataTaskFunCheck.call(request)
        completionHandler(completionHandlerStub.0, completionHandlerStub.1, completionHandlerStub.2)
        return dataTaskStub
    }
}
