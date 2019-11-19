//
//  FileManageable.swift
//  VidLoader
//
//  Created by Petre on 14.11.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import Foundation

protocol FileManageable {
    func removeItem(atPath path: String) throws
}

extension FileManager: FileManageable { }
