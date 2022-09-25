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
        contentInformationRequest?.contentType = response.mimeType |> generateAllowedContentType
        contentInformationRequest?.isByteRangeAccessSupported = true
        contentInformationRequest?.contentLength = response.expectedContentLength
        dataRequest?.respond(with: data)
        finishLoading()
    }
    
    private func generateAllowedContentType(mimeType: String?) -> String? {
        guard let allowedTypes = contentInformationRequest?.allowedContentTypes else {
            return mimeType
        }
        guard let contentType = allowedTypes.first(where: { $0 == mimeType }) else {
            return nil
        }
        return contentType
    }
}
