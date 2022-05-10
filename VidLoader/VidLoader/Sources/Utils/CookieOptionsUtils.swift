//
//  CookieOptionsUtils.swift
//  VidLoader
//
//  Created by Emmanouil Nicolas on 10/05/22.
//  Copyright © 2022 Petre. All rights reserved.
//

import AVFoundation

struct CookieOptionsUtils {
    static func createCookieOptionsWith(domain: String?, headers: [String: String]?) -> [String : Any]? {
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
