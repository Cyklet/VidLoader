//
//  MockSchemeHandler.swift
//  VidLoaderTests
//
//  Created by Petre on 12/6/19.
//  Copyright © 2019 Petre. All rights reserved.
//

@testable import VidLoader
import AVFoundation

struct MockSchemeHandler: SchemeHandleable {
    
    var urlAssetFunCheck = FuncCheck<URL?>()
    var urlAssetStub: Result<AVURLAsset, ResourceLoadingError> = .failure(.unknown)
    func urlAsset(with mediaURL: URL?) -> Result<AVURLAsset, ResourceLoadingError> {
        urlAssetFunCheck.call(mediaURL)
        return urlAssetStub
    }
    
    var persistentKeyFunCheck = FuncCheck<URL>()
    var persistentKeyStub: Data?
    func persistentKey(from url: URL) -> Data? {
        persistentKeyFunCheck.call(url)
        return persistentKeyStub
    }
}
