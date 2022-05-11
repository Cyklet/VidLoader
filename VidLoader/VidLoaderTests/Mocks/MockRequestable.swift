//
//  MockRequestable.swift
//  VidLoaderTests
//
//  Created by Petre on 03.12.19.
//  Copyright © 2019 Petre. All rights reserved.
//

@testable import VidLoader
import Foundation

final class MockRequestable: Requestable {

    var dataArrayStub: [Data] = []
    var completionHandlerStub: (Data?, URLResponse?, Error?)
    var dataTaskStub: CustomDataTask!
    var dataTaskFuncCheck = FuncCheck<URLRequest>()
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        dataTaskFuncCheck.call(request)
        let data = completionHandlerStub.0 ?? dataArrayStub.first
        dataArrayStub = Array(dataArrayStub.dropFirst())
        completionHandler(data, completionHandlerStub.1, completionHandlerStub.2)
        return dataTaskStub
    }
}
