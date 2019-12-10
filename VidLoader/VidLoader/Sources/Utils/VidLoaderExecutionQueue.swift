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
}

final class VidLoaderExecutionQueue: VidLoaderExecutionQueueable {
    private let queue: DispatchQueue

    init(label: String) {
        queue = DispatchQueue(label: label)
    }

    func async(execution: @escaping () -> Void) {
        queue.async { execution() }
    }
}
