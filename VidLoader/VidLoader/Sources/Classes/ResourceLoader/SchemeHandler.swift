//
//  SchemeHandler.swift
//  VidLoader
//
//  Created by Petre on 14.11.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import AVFoundation

protocol SchemeHandleable {
    func urlAsset(with mediaURL: URL?, data: Data) -> Result<AVURLAsset, ResourceLoadingError>
    func persistentKey(from url: URL) -> Data?
    func schemeType(from url: URL) -> SchemeType?
}

enum SchemeType: String {
    case key = "vidloader-encryption-key"
    case master = "vidloader-master"
    case variant = "vidloader-variant"
    case original = "https"
}

struct SchemeHandler: SchemeHandleable {
    func urlAsset(with mediaURL: URL?, data: Data) -> Result<AVURLAsset, ResourceLoadingError> {
        let schemeType = schemeType(from: data)
        guard let url = mediaURL?.withScheme(scheme: schemeType) else {
            return .failure(.urlScheme)
        }

        return .success(AVURLAsset(url: url))
    }

    func schemeType(from url: URL) -> SchemeType? {
        guard let scheme = url.scheme else {
            return nil
        }
        return SchemeType(rawValue: scheme)
    }

    func persistentKey(from url: URL) -> Data? {
        guard let adoptURL = url.withScheme(scheme: nil) else { return nil }

        return Data(base64Encoded: adoptURL.absoluteString)
    }
    
    // MARK: - Private
    
    private func schemeType(from data: Data) -> SchemeType {
        let variantChunkKey = "#EXTINF"
        guard let chunkData = variantChunkKey.data else {
            return .master
        }
        return data.range(of: chunkData) == nil ? .master : .variant
    }
}
