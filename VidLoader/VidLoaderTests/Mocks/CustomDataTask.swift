//
//  CustomDataTask.swift
//  VidLoaderTests
//
//  Created by Petre on 03.12.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import Foundation

final class CustomDataTask: URLSessionDataTask {
    var cancelFunCheck = EmptyFuncCheck()
    override func cancel() {
        cancelFunCheck.call()
    }

    var resumeFunCheck = EmptyFuncCheck()
    override func resume() {
        resumeFunCheck.call()
    }
}

extension CustomDataTask {
    // URLSessionDataTask.init() is deprecated in ios 13, maybe swizzling method to dodge it
    static func mocked() -> CustomDataTask {
        return CustomDataTask()
    }
}
