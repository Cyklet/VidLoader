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
    
    var urlAssetFuncCheck = FuncCheck<URL?>()
    var urlAssetStub: Result<AVURLAsset, ResourceLoadingError> = .failure(.unknown)
    func urlAsset(with mediaURL: URL?) -> Result<AVURLAsset, ResourceLoadingError> {
        urlAssetFuncCheck.call(mediaURL)
        return urlAssetStub
    }
    
    var persistentKeyFuncCheck = FuncCheck<URL>()
    var persistentKeyStub: Data?
    func persistentKey(from url: URL) -> Data? {
        persistentKeyFuncCheck.call(url)
        return persistentKeyStub
    }
}
