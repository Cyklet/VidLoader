//
//  SchemeHandler.swift
//  VidLoader
//
//  Created by Petre on 14.11.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import AVFoundation

protocol SchemeHandleable {
    func urlAsset(with mediaURL: URL?) -> Result<AVURLAsset, ResourceLoadingError>
    func persistentKey(from url: URL) -> Data?
}

enum SchemeType: String {
    case key = "vidloader-encryption-key"
    case custom = "vidloader-new-scheme"
    case original = "https"
}

struct SchemeHandler: SchemeHandleable {
    func urlAsset(with mediaURL: URL?) -> Result<AVURLAsset, ResourceLoadingError> {
        guard let url = mediaURL?.withScheme(scheme: .custom) else {
            return .failure(.urlScheme)
        }

        return .success(AVURLAsset(url: url))
    }

    func persistentKey(from url: URL) -> Data? {
        guard url.scheme == SchemeType.key.rawValue,
            let adoptURL = url.withScheme(scheme: nil) else { return nil }

        return Data(base64Encoded: adoptURL.absoluteString)
    }
}
