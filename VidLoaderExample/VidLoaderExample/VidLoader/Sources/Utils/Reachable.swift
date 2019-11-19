//
//  Reachable.swift
//  VidLoader
//
//  Created by Petre on 01.09.19.
//  Copyright © 2019 Petre. All rights reserved.
//

protocol Reachable {
    var connection: Reachability.Connection { get }
    func startNotifier() throws
}

extension Reachability: Reachable { }
