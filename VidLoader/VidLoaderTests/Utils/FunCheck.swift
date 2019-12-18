//
//  FuncCheck.swift
//  VidLoaderTests
//
//  Created by Petre on 12/6/19.
//  Copyright © 2019 Petre. All rights reserved.
//

class FuncCheck<T> {
    private(set) var arguments: T?
    private(set) var count = 0

    func call(_ arguments: T) {
        count += 1
        self.arguments = arguments
    }

    func reset() {
        arguments = nil
        count = 0
    }
}

extension FuncCheck where T: Equatable {
    func wasCalled(with expectedArguments: T) -> Bool {
        return count != 0 && self.arguments == expectedArguments
    }
}

final class EmptyFuncCheck: FuncCheck<()> {
    func call() {
        super.call(())
    }
    
    func wasCalled() -> Bool {
        return count != 0
    }
}
