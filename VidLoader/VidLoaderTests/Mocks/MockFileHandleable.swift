//
//  MockFileHandleable.swift
//  VidLoaderTests
//
//  Created by Petre on 12/11/19.
//  Copyright © 2019 Petre. All rights reserved.
//

@testable import VidLoader

final class MockFileHandleable: FileHandleable {
    var deleteContentFuncCheck = FuncCheck<ItemInformation>()
    func deleteContent(for item: ItemInformation) {
        deleteContentFuncCheck.call(item)
    }
}
