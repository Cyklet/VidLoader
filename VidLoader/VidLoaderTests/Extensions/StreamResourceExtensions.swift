//
//  StreamResourceExtensions.swift
//  VidLoaderTests
//
//  Created by Petre on 03.12.19.
//  Copyright © 2019 Petre. All rights reserved.
//

@testable import VidLoader
import Foundation

extension StreamResource {
    static func mock(response: HTTPURLResponse = .mock(), data: Data = .mock()) -> StreamResource {
        return StreamResource(response: response, data: data)
    }
}
