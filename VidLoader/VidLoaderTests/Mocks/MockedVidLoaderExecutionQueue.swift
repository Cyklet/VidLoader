//
//  MockedVidLoaderExecutionQueue.swift
//  VidLoaderTests
//
//  Created by Petre on 12/6/19.
//  Copyright © 2019 Petre. All rights reserved.
//

@testable import VidLoader

final class MockedVidLoaderExecutionQueue: VidLoaderExecutionQueueable {
    
    var asyncDidCall: Bool?
    func async(execution: @escaping () -> Void) {
        asyncDidCall = true
        execution()
    }
    
}
