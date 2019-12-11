//
//  VidObserver.swift
//  VidLoader
//
//  Created by Petre on 14.11.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import Foundation

/// Observe types that can be used to handle download states
public enum ObserverType: Hashable, Equatable {
    /// Only observer with identifier will be fired
    case single(String)
    /// All observer of all downloads will be fired
    case all
}

/// VidObserver is used as a storage for state changed closure, working as an observer that is firing when the state of the item is changing
public class VidObserver: NSObject {
    let type: ObserverType
    let stateChanged: (ItemInformation) -> Void

    public init(type: ObserverType, stateChanged: @escaping (ItemInformation) -> Void) {
        self.type = type
        self.stateChanged = stateChanged
    }
}
