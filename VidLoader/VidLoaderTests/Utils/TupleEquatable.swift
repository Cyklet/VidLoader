//
//  TupleEquatable.swift
//  VidLoaderTests
//
//  Created by Petre on 03.12.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import Foundation

func ==<T1: Equatable, T2: Equatable>(lhs: (T1, T2)?, rhs: (T1, T2)?) -> Bool {
    return lhs?.0 == rhs?.0 && lhs?.1 == rhs?.1
}
