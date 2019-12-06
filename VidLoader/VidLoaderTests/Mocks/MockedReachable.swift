//
//  MockedReachable.swift
//  VidLoaderTests
//
//  Created by Petre on 12/6/19.
//  Copyright © 2019 Petre. All rights reserved.
//

@testable import VidLoader

final class MockedReachable: Reachable {
    var connection: Reachability.Connection = .unavailable
    
    var startNotifierDidCall: Bool?
    func startNotifier() throws {
        startNotifierDidCall = true
    }
}
