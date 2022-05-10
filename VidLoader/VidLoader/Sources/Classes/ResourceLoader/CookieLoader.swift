//
//  CookieLoader.swift
//  VidLoader
//
//  Created by Emmanouil Nicolas on 10/05/22.
//  Copyright © 2022 Petre. All rights reserved.
//

import AVFoundation

final class CookieLoader: NSObject, AVAssetResourceLoaderDelegate {
    
    //MARK: - Propeties
    let queue = DispatchQueue(label: "com.vidloader.resource_loader_cookies_dispatch_url")
    private let headers: [String: String]
    
    //MARK: - Init
    init(headers: [String: String]) {
        self.headers = headers
    }
    
    // MARK: - AVAssetResourceLoaderDelegate
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader,
                        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        guard let url = loadingRequest.request.url else { return false }
        loadingRequest.process(url: url, cookies: headers)
        return true
    }
}
