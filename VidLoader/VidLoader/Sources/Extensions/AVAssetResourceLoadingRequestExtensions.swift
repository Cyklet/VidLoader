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
}
