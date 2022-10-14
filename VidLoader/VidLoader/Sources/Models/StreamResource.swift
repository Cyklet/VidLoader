//
//  StreamResource.swift
//  VidLoader
//
//  Created by Petre on 01.09.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import Foundation

struct StreamResource: Equatable {
    let response: HTTPURLResponse
    let data: Data
    
    init(response: HTTPURLResponse, data: Data) {
        self.response = response
        self.data = data
    }
}
