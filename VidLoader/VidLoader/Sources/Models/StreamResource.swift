//
//  StreamResource.swift
//  VidLoader
//
//  Created by Petre on 01.09.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import Foundation

private let variantChunkKey = "#EXTINF"

struct StreamResource: Equatable {
    enum FileType {
        case master
        case variant
    }
    let response: HTTPURLResponse
    let data: Data
    let fileType: FileType
    
    init(response: HTTPURLResponse, data: Data) {
        self.response = response
        self.data = data
        switch variantChunkKey.data {
        case let .some(chunkKey):
            fileType = data.range(of: chunkKey) == nil ? .master : .variant
        case .none:
            fileType = .master
        }
    }
}
