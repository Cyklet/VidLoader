//
//  DataExtensions.swift
//  VidLoader
//
//  Created by Petre on 01.09.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import Foundation

extension Data {
    var string: String? {
        return String(data: self, encoding: .utf8)
    }
}
