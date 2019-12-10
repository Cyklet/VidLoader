//
//  M3U8Error.swift
//  VidLoader
//
//  Created by Petre on 14.11.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import Foundation

enum M3U8Error: Error, Equatable {
    case dataConversion
    case keyURLMissing
    case keyContentWrong
    case custom(VidLoaderError?)
}
