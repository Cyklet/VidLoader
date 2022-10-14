//
//  MockSchemeHandler.swift
//  VidLoaderTests
//
//  Created by Petre on 12/6/19.
//  Copyright © 2019 Petre. All rights reserved.
//

@testable import VidLoader
import AVFoundation

final class MockSchemeHandler: SchemeHandleable {

    var persistentKeyFuncCheck = FuncCheck<URL>()
    var persistentKeyStub: Data?
    func persistentKey(from url: URL) -> Data? {
        persistentKeyFuncCheck.call(url)
        return persistentKeyStub
    }

    var urlAssetFuncCheck = FuncCheck<(URL?, Data)>()
    var urlAssetStub: Result<AVURLAsset, ResourceLoadingError> = .failure(.unknown)
    func urlAsset(with mediaURL: URL?, data: Data) -> Result<AVURLAsset, ResourceLoadingError> {
        urlAssetFuncCheck.call((mediaURL, data))
        return urlAssetStub
    }
    
    var schemeTypeFuncCheck = FuncCheck<URL>()
    var schemeTypeStub: SchemeType?
    func schemeType(from url: URL) -> SchemeType? {
        schemeTypeFuncCheck.call(url)
        return schemeTypeStub
    }
}
