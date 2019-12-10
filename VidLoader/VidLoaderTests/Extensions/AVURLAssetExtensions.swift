//
//  AVURLAssetExtensions.swift
//  VidLoaderTests
//
//  Created by Petre on 12/10/19.
//  Copyright © 2019 Petre. All rights reserved.
//

import AVFoundation

extension AVURLAsset {
    static func mock(url: URL = .mock()) -> AVURLAsset {
        return AVURLAsset(url: url)
    }
}

