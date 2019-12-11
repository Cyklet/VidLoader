//
//  CustomDataTask.swift
//  VidLoaderTests
//
//  Created by Petre on 03.12.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import Foundation

final class CustomDataTask: URLSessionDataTask {
    var cancelFuncCheck = EmptyFuncCheck()
    override func cancel() {
        cancelFuncCheck.call()
    }

    var resumeFuncCheck = EmptyFuncCheck()
    override func resume() {
        resumeFuncCheck.call()
    }
}

extension CustomDataTask {
    // URLSessionDataTask.init() is deprecated in ios 13, maybe swizzling method to dodge it
    static func mock() -> CustomDataTask {
        return CustomDataTask()
    }
}
