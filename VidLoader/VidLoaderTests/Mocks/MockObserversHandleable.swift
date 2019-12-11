//
//  MockObserversHandleable.swift
//  VidLoaderTests
//
//  Created by Petre on 12/11/19.
//  Copyright © 2019 Petre. All rights reserved.
//

@testable import VidLoader

final class MockObserversHandleable: ObserversHandleable {
    
    var addFuncCheck = FuncCheck<VidObserver?>()
    func add(_ observer: VidObserver?) {
        addFuncCheck.call(observer)
    }
    
    var removeFuncCheck = FuncCheck<VidObserver?>()
    func remove(_ observer: VidObserver?) {
        removeFuncCheck.call(observer)
    }
    
    var fireFuncCheck = FuncCheck<(ObserverType, ItemInformation)>()
    func fire(for type: ObserverType, with item: ItemInformation) {
        fireFuncCheck.call((type, item))
    }
}

