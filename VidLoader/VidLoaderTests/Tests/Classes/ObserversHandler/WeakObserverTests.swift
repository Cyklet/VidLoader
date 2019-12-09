//
//  WeakObserverTests.swift
//  VidLoaderTests
//
//  Created by Petre on 12/9/19.
//  Copyright © 2019 Petre. All rights reserved.
//

import XCTest
@testable import VidLoader

final class WeakObserverTests: XCTestCase {

    func test_CheckObjectReference_Released_ObjectReferenceReleased() {
        // GIVEN
        var object: NSObject? = NSObject()
        let weakObserver: WeakObserver<NSObject>? = object.flatMap(WeakObserver.init)
        
        // WHEN
        object = nil
        
        // THEN
        XCTAssertNil(weakObserver?.reference)
    }
    
    func test_CheckObjectReference_NotReleased_ObjectReferenceExist() {
        // GIVEN
        let object: NSObject = NSObject()
       
        // WHEN
        let weakObserver: WeakObserver<NSObject> = WeakObserver(reference: object)
        
        // THEN
        XCTAssertEqual(weakObserver.reference, object)
    }
}
