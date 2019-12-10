//
//  ResourcesDelegatesHandlerTests.swift
//  VidLoaderTests
//
//  Created by Petre on 12/6/19.
//  Copyright © 2019 Petre. All rights reserved.
//

import XCTest
@testable import VidLoader

final class ResourcesDelegatesHandlerTests: XCTestCase {
    private var delegatesHandler: ResourcesDelegatesHandler!
    
    override func setUp() {
        super.setUp()
        
        delegatesHandler = ResourcesDelegatesHandler()
    }
    
    func test_AddDelegate_EmptyArray_ArrayHasOneItem() {
        // GIVEN
        let identifier = "itemIdentifier"
        let loader = ResourceLoader(observer: .init(taskDidFail: { _ in }, keyDidLoad: { }),
                                    streamResource: StreamResource(response: .mock(), data: .mock()))
        let expectedResources = [identifier: loader]
        
        // WHEN
        delegatesHandler.add(identifier: identifier, loader: loader)
        let resultResources = delegatesHandler.resourcesLoaders
        
        // THEN
        XCTAssertEqual(expectedResources, resultResources)
    }
    
    func test_AddDelegate_AlreadyExist_ArrayHasOneItem() {
        // GIVEN
        let identifier = "itemIdentifier"
        let loader = ResourceLoader(observer: .init(taskDidFail: { _ in }, keyDidLoad: { }),
                                    streamResource: StreamResource(response: .mock(), data: .mock()))
        let expectedResources = [identifier: loader]
        delegatesHandler.add(identifier: identifier, loader: loader)
        
        // WHEN
        delegatesHandler.add(identifier: identifier, loader: loader)
        let resultResources = delegatesHandler.resourcesLoaders
        
        // THEN
        XCTAssertEqual(expectedResources, resultResources)
    }
    
    func test_KeepResources_NothingToKeep_ResultIsEmpty() {
        // GIVEN
        let identifier = "itemIdentifier"
        let loader = ResourceLoader(observer: .init(taskDidFail: { _ in }, keyDidLoad: { }),
                                    streamResource: StreamResource(response: .mock(), data: .mock()))
        let expectedResources = [String: ResourceLoader]()
        delegatesHandler.add(identifier: identifier, loader: loader)
        
        // WHEN
        delegatesHandler.keep(identifiers: [])
        let resultResources = delegatesHandler.resourcesLoaders
        
        // THEN
        XCTAssertEqual(expectedResources, resultResources)
    }
    
    func test_KeepResources_ItemExist_ResourceHasKept() {
        // GIVEN
        let identifier = "itemIdentifier"
        let loader = ResourceLoader(observer: .init(taskDidFail: { _ in }, keyDidLoad: { }),
                                    streamResource: StreamResource(response: .mock(), data: .mock()))
        let expectedResources = [identifier: loader]
        delegatesHandler.add(identifier: identifier, loader: loader)
        
        // WHEN
        delegatesHandler.keep(identifiers: [identifier])
        let resultResources = delegatesHandler.resourcesLoaders
        
        // THEN
        XCTAssertEqual(expectedResources, resultResources)
    }
    
    func test_KeepNewIdentifier_NoIdInArray_ResultIsEmpty() {
        // GIVEN
        let identifier = "itemIdentifier"
        let loader = ResourceLoader(observer: .init(taskDidFail: { _ in }, keyDidLoad: { }),
                                    streamResource: StreamResource(response: .mock(), data: .mock()))
        let expectedResources = [String: ResourceLoader]()
        delegatesHandler.add(identifier: identifier, loader: loader)
        
        // WHEN
        delegatesHandler.keep(identifiers: ["randomIdentifier"])
        let resultResources = delegatesHandler.resourcesLoaders
        
        // THEN
        XCTAssertEqual(expectedResources, resultResources)
    }
}
