//
//  VidObserver.swift
//  VidLoader
//
//  Created by Petre on 14.11.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import Foundation

public enum ObserverType: Hashable {
    case single(String)
    case all
}

public class VidObserver: NSObject {
    let type: ObserverType
    let stateChanged: (ItemInformation) -> Void

    public init(type: ObserverType, stateChanged: @escaping (ItemInformation) -> Void) {
        self.type = type
        self.stateChanged = stateChanged
    }
}
