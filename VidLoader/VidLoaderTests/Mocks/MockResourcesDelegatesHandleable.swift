//
//  MockResourcesDelegatesHandleable.swift
//  VidLoaderTests
//
//  Created by Petre on 12/11/19.
//  Copyright © 2019 Petre. All rights reserved.
//

@testable import VidLoader

final class MockResourcesDelegatesHandleable: ResourcesDelegatesHandleable {
    var keepFuncCheck = FuncCheck<[String]>()
    func keep(identifiers: [String]) {
        keepFuncCheck.call(identifiers)
    }
    
    var addFuncCheck = FuncCheck<(String, ResourceLoader)>()
    func add(identifier: String, loader: ResourceLoader) {
        addFuncCheck.call((identifier, loader))
    }
}
