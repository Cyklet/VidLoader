//
//  AVAssetResourceLoadingRequestExtensions.swift
//  VidLoaderExample
//
//  Created by Petre on 14.11.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import AVFoundation

extension AVAssetResourceLoadingRequest {
    @objc public func setup(response: URLResponse, data: Data) {
        contentInformationRequest?.contentType = response.mimeType
        contentInformationRequest?.isByteRangeAccessSupported = true
        contentInformationRequest?.contentLength = response.expectedContentLength
        dataRequest?.respond(with: data)
        finishLoading()
    }
    
    @objc public func process(url: URL, cookies: [String: String]) {
        guard let cookies = CookieOptionsUtils.createCookieOptionsWith(domain: url.host, headers: cookies) else { return }
        var redirectRequest = URLRequest(url: url)
        for key in cookies.keys {
            if let value = cookies[key] as? String {
                redirectRequest.addValue(value, forHTTPHeaderField: key)
            }
        }
        self.redirect = redirectRequest
        finishLoading()
    }
}
