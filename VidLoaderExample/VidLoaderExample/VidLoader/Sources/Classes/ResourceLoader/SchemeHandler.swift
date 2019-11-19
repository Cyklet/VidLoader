//
//  SchemeHandler.swift
//  VidLoader
//
//  Created by Petre on 14.11.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import AVFoundation

struct SchemeHandler {
    let keyScheme = "vidloader-ecnryption-key"
    let newScheme = "vidloader-new-scheme"
    let validScheme = "https"

    func urlAsset(with mediaURL: URL?) -> Result<AVURLAsset, ResourceLoadingError> {
        guard let url = mediaURL?.withScheme(scheme: newScheme) else {
            return .failure(.urlScheme)
        }

        return .success(AVURLAsset(url: url))
    }

    func persistentKey(from url: URL) -> Data? {
        guard url.scheme == keyScheme,
            let adoptURL = url.withScheme(scheme: nil) else { return nil }

        return Data(base64Encoded: adoptURL.absoluteString)
    }
}
