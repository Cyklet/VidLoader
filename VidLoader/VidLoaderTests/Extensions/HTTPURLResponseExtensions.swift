//
//  HTTPURLResponseExtensions.swift
//  VidLoaderTests
//
//  Created by Petre on 03.12.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import Foundation

extension HTTPURLResponse {
    static func mocked(url: URL = .mocked(), mimeType: String? = nil,
                       expectedContentLength: Int = 0, textEncodingName: String? = nil) -> HTTPURLResponse {
        return HTTPURLResponse(url: url, mimeType: mimeType,
                               expectedContentLength: expectedContentLength, textEncodingName: textEncodingName)
    }
}

