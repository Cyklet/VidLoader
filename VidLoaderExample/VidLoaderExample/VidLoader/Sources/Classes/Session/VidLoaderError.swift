//
//  VidLoaderError.swift
//  VidLoader
//
//  Created by Petre on 14.11.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import Foundation

public struct VidLoaderError: Error, Codable, Equatable {
    let code: Int
    let description: String
    let localizedDescription: String
    let domain: String

    init(error: Error) {
        let nsError = error as NSError
        self.code = nsError.code
        self.description = nsError.description
        self.localizedDescription = nsError.localizedDescription
        self.domain = nsError.domain
    }
}
