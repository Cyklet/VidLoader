//
//  MockReachable.swift
//  VidLoaderTests
//
//  Created by Petre on 12/6/19.
//  Copyright © 2019 Petre. All rights reserved.
//

@testable import VidLoader

final class MockReachable: Reachable {
    var connection: Reachability.Connection = .unavailable
    
    var startNotifierFunCheck = EmptyFuncCheck()
    func startNotifier() throws {
        startNotifierFunCheck.call()
    }
}
