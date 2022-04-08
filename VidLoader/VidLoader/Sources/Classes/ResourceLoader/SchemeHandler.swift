//
//  SchemeHandler.swift
//  VidLoader
//
//  Created by Petre on 14.11.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import AVFoundation

protocol SchemeHandleable {
    func urlAsset(with mediaURL: URL?, headers: [String: String]?) -> Result<AVURLAsset, ResourceLoadingError>
    func persistentKey(from url: URL) -> Data?
}

enum SchemeType: String {
    case key = "vidloader-encryption-key"
    case custom = "vidloader-new-scheme"
    case original = "https"
}

struct SchemeHandler: SchemeHandleable {
    
    func urlAsset(with mediaURL: URL?, headers: [String: String]?) -> Result<AVURLAsset, ResourceLoadingError> {
        guard let url = mediaURL?.withScheme(scheme: .custom) else {
            return .failure(.urlScheme)
        }
        
        let options = createCookieOptionsWith(domain: mediaURL?.host, headers: headers)
        return .success(AVURLAsset(url: url, options: options))
    }
    
    func persistentKey(from url: URL) -> Data? {
        guard url.scheme == SchemeType.key.rawValue,
              let adoptURL = url.withScheme(scheme: nil) else { return nil }
        
        return Data(base64Encoded: adoptURL.absoluteString)
    }
    
    private func createCookieOptionsWith(domain: String?, headers: [String: String]?) -> [String : Any]? {
        guard let domain = domain else { return nil }
        
        if let headers = headers {
            for key in headers.keys {
                let cookie: [HTTPCookiePropertyKey : Any] = [
                    HTTPCookiePropertyKey.domain: domain,
                    HTTPCookiePropertyKey.path: "/",
                    HTTPCookiePropertyKey.secure: true,
                    HTTPCookiePropertyKey.init("HttpsOnly"): true,
                    HTTPCookiePropertyKey.value: headers[key] ?? "",
                    HTTPCookiePropertyKey.name: key
                ]
                if let httpCookie = HTTPCookie(properties: cookie) {
                    HTTPCookieStorage.shared.setCookie(httpCookie)
                }
            }
        }
        
        guard let cookies = HTTPCookieStorage.shared.cookies else { return nil }
        return [AVURLAssetHTTPCookiesKey: cookies]
    }
}
