//
//  MockAVAssetResourceLoaderDelegate.swift
//  VidLoaderTests
//
//  Created by Petre on 12/11/19.
//  Copyright © 2019 Petre. All rights reserved.
//

@testable import VidLoader
import Foundation

final class MockKeyLoadable: NSObject, KeyLoadable {
    var queueFuncCheck = EmptyFuncCheck()
    var queueStub: DispatchQueue = .init(label: "mock_key_loadable")
    var queue: DispatchQueue {
        set {
            queueStub = newValue
        }
        get {
            queueFuncCheck.call()
            return queueStub
        }
    }
}
