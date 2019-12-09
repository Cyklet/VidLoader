//
//  WeakObserver.swift
//  VidLoader
//
//  Created by Petre on 14.11.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import Foundation

struct WeakObserver<T: AnyObject> where T: Equatable {
    private(set) weak var reference: T?

    init(reference: T) {
        self.reference = reference
    }
}

extension WeakObserver: Equatable {
    static func == (lhs: WeakObserver<T>, rhs: WeakObserver<T>) -> Bool {
        return lhs.reference == rhs.reference
    }
}
