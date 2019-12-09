//
//  ResourcesDelegatesHandler.swift
//  VidLoader
//
//  Created by Petre on 14.11.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import AVFoundation

protocol ResourcesDelegatesHandleable{
    func keep(identifiers: [String])
    func add(identifier: String, loader: ResourceLoader)
}

final class ResourcesDelegatesHandler: ResourcesDelegatesHandleable {
    private(set) var resourcesLoaders: [String: ResourceLoader] = [:]

    // MARK: - ResourcesDelegatesHandleable

    func add(identifier: String, loader: ResourceLoader) {
        resourcesLoaders[identifier] = loader
    }

    func keep(identifiers: [String]) {
        let tuples = identifiers.compactMap { identifier -> (String, ResourceLoader)? in
            guard let loader = resourcesLoaders[identifier] else { return nil }
            return (identifier, loader)
        }
        resourcesLoaders = Dictionary(tuples, uniquingKeysWith: { $1 })
    }
}
