//
//  CustomDataTask.swift
//  VidLoaderTests
//
//  Created by Petre on 03.12.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import Foundation

extension CustomDataTask {
    // URLSessionDataTask.init() is deprecated in ios 13, maybe swizzling method to dodge it
    static func mocked() -> CustomDataTask {
        return CustomDataTask()
    }
}

final class CustomDataTask: URLSessionDataTask {
    var cancelDidCall: Bool?
    override func cancel() {
        cancelDidCall = true
    }

    var resumeDidCall: Bool?
    override func resume() {
        resumeDidCall = true
    }
}
