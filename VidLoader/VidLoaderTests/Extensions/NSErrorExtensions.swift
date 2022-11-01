//
//  NSErrorExtensions.swift
//  VidLoaderTests
//
//  Created by Petre Plotnic on 15.10.22.
//  Copyright © 2022 Petre. All rights reserved.
//

import Foundation

extension NSError {
    static func mock(domain: String = "", code: Int = 0, userInfo: [String: Any]? = nil) -> NSError {
        return NSError(domain: domain, code: code, userInfo: userInfo)
    }
}
