//
//  Lens.swift
//  VidLoader
//
//  Created by Petre on 01.09.19.
//  Copyright © 2019 Petre. All rights reserved.
//

public struct Lens<Whole, Part> {
    public let get: (Whole) -> Part
    public let set: (Part, Whole) -> Whole

    public init(get: @escaping (Whole) -> Part, set: @escaping (Part, Whole) -> Whole) {
        self.get = get
        self.set = set
    }
}
