//
//  KeyLoader.swift
//  VidLoader
//
//  Created by Petre on 14.11.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import AVFoundation

protocol KeyLoadable: AVAssetResourceLoaderDelegate {
    var queue: DispatchQueue { get }
}

final class KeyLoader: NSObject, KeyLoadable {
    private let schemeHandler: SchemeHandleable
    let queue = DispatchQueue(label: "com.vidloader.resource_loader_key_dispatch_url")
    
    init(schemeHandler: SchemeHandleable = SchemeHandler.init()) {
        self.schemeHandler = schemeHandler
    }

    // MARK: - AVAssetResourceLoaderDelegate

    func resourceLoader(_ resourceLoader: AVAssetResourceLoader,
                        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        guard let url = loadingRequest.request.url else { return false }
        if let persistentKey = schemeHandler.persistentKey(from: url) {
            queue.asyncAfter(deadline: .now() + 0.01, execute: {
                let keyResponse = URLResponse(url: url,
                                              mimeType: AVStreamingKeyDeliveryPersistentContentKeyType,
                                              expectedContentLength: persistentKey.count,
                                              textEncodingName: nil)
                loadingRequest.setup(response: keyResponse, data: persistentKey, isEntireLengthAvailableOnDemand: false)
            })
        }

        return true
    }
}
