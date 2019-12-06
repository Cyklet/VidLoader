//
//  MockedFileManager.swift
//  VidLoaderTests
//
//  Created by Petre on 12/6/19.
//  Copyright © 2019 Petre. All rights reserved.
//

@testable import VidLoader

final class MockedFileManager: FileManageable {
    
    var removeItemDidCall: Bool?
    func removeItem(atPath path: String) throws {
        removeItemDidCall = true
    }
    
}
