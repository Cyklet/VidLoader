//
//  ObserversHandlerTests.swift
//  VidLoaderTests
//
//  Created by Petre on 12/9/19.
//  Copyright © 2019 Petre. All rights reserved.
//
import XCTest
@testable import VidLoader

final class ObserversHandlerTests: XCTestCase {
    private var observersHandler: ObserversHandler!
    
    override func setUp() {
        super.setUp()
        
        observersHandler = ObserversHandler(observers: [:])
    }
    
    func test_FireObserver_ItemRemoved_ClosureNotCalled() {
                // GIVEN
        var resultItem: ItemInformation?
        let observer = VidObserver(type: .all, stateChanged: { item in resultItem = item })
        observersHandler.add(observer)
        
        // WHEN
        observersHandler.remove(observer)
        observersHandler.fire(for: .all, with: .mocked())
        
        // THEN
        XCTAssertNil(resultItem)
    }
    
    func test_FireObserver_ItemRemovedObserversRemained_ClosureCalled() {
                // GIVEN
        let expectedItem = ItemInformation.mocked(identifier: "I_am_expected_>_<")
        var resultItem: ItemInformation?
        let observerToRemove = VidObserver(type: .all, stateChanged: { item in resultItem = item })
        let observer = VidObserver(type: .all, stateChanged: { item in resultItem = item })
        observersHandler.add(observer)
        observersHandler.add(observerToRemove)
        
        // WHEN
        observersHandler.remove(observerToRemove)
        observersHandler.fire(for: .all, with: expectedItem)
        
        // THEN
        XCTAssertEqual(expectedItem, resultItem)
    }
    
    func test_FireAllTypeObserver_ItemExist_ClosureCalled() {
        // GIVEN
        let expectedItem = ItemInformation.mocked()
        var resultItem: ItemInformation?
        let observer = VidObserver(type: .all, stateChanged: { item in resultItem = item })
        observersHandler.add(observer)
        
        // WHEN
        observersHandler.fire(for: .all, with: expectedItem)
        
        // THEN
        XCTAssertEqual(expectedItem, resultItem)
    }
    
    func test_FireAllTypeObserver_ForItemTypeSingle_ClosureNotCalled() {
        // GIVEN
        let givenIdentifier = "do_I_exist"
        var resultItem: ItemInformation?
        let observer = VidObserver(type: .single(givenIdentifier), stateChanged: { item in resultItem = item })
        observersHandler.add(observer)
        
        // WHEN
        observersHandler.fire(for: .all, with: .mocked(identifier: "do_I_exist"))
        
        // THEN
        XCTAssertNil(resultItem)
    }
    
    func test_FireSingleTypeObserver_ItemExist_ClosureCalled() {
        // GIVEN
        let givenIdentifier = "do_I_exist"
        let expectedItem = ItemInformation.mocked(identifier: givenIdentifier)
        var resultItem: ItemInformation?
        let observer = VidObserver(type: .single(givenIdentifier), stateChanged: { item in resultItem = item })
        observersHandler.add(observer)
        
        // WHEN
        observersHandler.fire(for: .single(givenIdentifier), with: expectedItem)
        
        // THEN
        XCTAssertEqual(expectedItem, resultItem)
    }
    
    func test_FireSingleTypeObserver_ItemNotExist_ClosureCalled() {
        // GIVEN
        let givenIdentifier = "item_that_exist"
        let fireIdentifier = "do_I_exist"
        var resultItem: ItemInformation?
        let observer = VidObserver(type: .single(givenIdentifier), stateChanged: { item in resultItem = item })
        observersHandler.add(observer)
        
        // WHEN
        observersHandler.fire(for: .single(fireIdentifier), with: .mocked(identifier: fireIdentifier))
        
        // THEN
        XCTAssertNil(resultItem)
    }
    
    func test_FireAllTypeObserver_ReferenceReleased_ClosureNotCalled() {
        // GIVEN
        var resultItem: ItemInformation?
        var observer: VidObserver? = VidObserver(type: .all, stateChanged: { item in resultItem = item })
        observer.flatMap(observersHandler.add)
        observer = nil
        
        // WHEN
        observersHandler.fire(for: .all, with: .mocked())
        
        // THEN
        XCTAssertNil(resultItem)
    }
}
