//
//  VidLoaderHandler.swift
//  VidLoaderExample
//
//  Created by Petre on 18.10.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import VidLoader

final class VidLoaderHandler {
    static let shared = VidLoaderHandler()
    let loader: VidLoadable

    private init() {
        loader = VidLoader()
    }
}
