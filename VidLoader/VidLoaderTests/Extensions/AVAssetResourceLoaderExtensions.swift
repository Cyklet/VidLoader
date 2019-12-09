//
//  AVAssetResourceLoaderExtensions.swift
//  VidLoaderTests
//
//  Created by Petre on 12/9/19.
//  Copyright © 2019 Petre. All rights reserved.
//

import AVFoundation

extension AVAssetResourceLoader {
    static func mocked(url: URL = .mocked()) -> AVAssetResourceLoader {
        return AVURLAsset(url: url).resourceLoader
    }
}
