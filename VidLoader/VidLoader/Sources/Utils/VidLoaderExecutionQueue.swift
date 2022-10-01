//
//  VidLoaderExecutionQueue.swift
//  VidLoader
//
//  Created by Petre on 01.09.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import Foundation

protocol VidLoaderExecutionQueueable {
    func async(execution: @escaping () -> Void)
    func asyncAfter(deadline: DispatchTime, execution: @escaping() -> Void)
}

final class VidLoaderExecutionQueue: VidLoaderExecutionQueueable {
    private let queue: DispatchQueue

    init(label: String) {
        queue = DispatchQueue(label: label)
    }

    func async(execution: @escaping () -> Void) {
        queue.async { execution() }
    }
    
    func asyncAfter(deadline: DispatchTime, execution: @escaping() -> Void) {
        queue.asyncAfter(deadline: deadline, execute: execution)
    }
}
