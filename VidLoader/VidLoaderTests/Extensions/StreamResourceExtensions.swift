//
//  StreamResourceExtensions.swift
//  VidLoaderTests
//
//  Created by Petre on 03.12.19.
//  Copyright © 2019 Petre. All rights reserved.
//

@testable import VidLoader

extension StreamResource {
    static func mocked(response: HTTPURLResponse = .mocked(), data: Data = .mocked()) -> StreamResource {
        return StreamResource(response: response, data: data)
    }
}
