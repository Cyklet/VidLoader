//
//  MockVidLoaderExecutionQueue.swift
//  VidLoaderTests
//
//  Created by Petre on 12/6/19.
//  Copyright © 2019 Petre. All rights reserved.
//

@testable import VidLoader

final class MockVidLoaderExecutionQueue: VidLoaderExecutionQueueable {
    
    var asyncAfterFuncCheck = FuncCheck<DispatchTime>()
    func asyncAfter(deadline: DispatchTime, execution: @escaping () -> Void) {
        asyncAfterFuncCheck.call(deadline)
        execution()
    }
    
    var asyncFuncCheck = EmptyFuncCheck()
    func async(execution: @escaping () -> Void) {
        asyncFuncCheck.call()
        execution()
    }
    
}
