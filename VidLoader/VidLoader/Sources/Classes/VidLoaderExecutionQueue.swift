//
//  VidLoaderExecutionQueue.swift
//  VidLoader
//
//  Created by Petre on 01.09.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import Foundation

protocol VidLoaderExecutionQueueable {
    func async(label: String, execution: @escaping () -> Void)
}

final class VidLoaderExecutionQueue: VidLoaderExecutionQueueable {
    func async(label: String, execution: @escaping () -> Void) {
        DispatchQueue(label: label).async {
            execution()
        }
    }
}
