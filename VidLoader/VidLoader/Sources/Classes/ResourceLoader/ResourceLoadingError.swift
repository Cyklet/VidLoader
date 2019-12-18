//
//  ResourceLoadingError.swift
//  VidLoader
//
//  Created by Petre on 14.11.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import Foundation

enum ResourceLoadingError: Error {
    case unknown
    case urlScheme
    case m3u8(M3U8Error)
    case custom(VidLoaderError)
}
