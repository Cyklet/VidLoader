//
//  Atomic.swift
//  VidLoader
//
//  Created by Petre on 01.09.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import Foundation

final class Atomic<A> {
    private var _value: A
    private lazy var queue: DispatchQueue = {
        return DispatchQueue(label: "com.vidloader.atomic_variable_" + Date().timeIntervalSince1970.description)
    }()

    init(_ value: A) {
        self._value = value
    }

    var value: A {
        get {
            return queue.sync { _value }
        }
        set {
            queue.sync { _value = newValue }
        }
    }
}
