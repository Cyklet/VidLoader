//
//  DataExtensions.swift
//  VidLoaderTests
//
//  Created by Petre on 03.12.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import Foundation

extension Data {
    static func mock(string: String = "") -> Data {
        guard let data = string.data(using: .utf8) else {
            fatalError("mock Data is nil for string: \(string)")
        }
        return data
    }
}
