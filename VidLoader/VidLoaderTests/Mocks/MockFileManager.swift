//
//  MockFileManager.swift
//  VidLoaderTests
//
//  Created by Petre on 12/6/19.
//  Copyright © 2019 Petre. All rights reserved.
//

@testable import VidLoader

final class MockFileManager: FileManageable {
    
    var removeItemFunCheck = FuncCheck<String>()
    func removeItem(atPath path: String) throws {
        removeItemFunCheck.call(path)
    }
    
}
