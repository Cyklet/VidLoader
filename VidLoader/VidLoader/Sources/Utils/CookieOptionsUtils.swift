//
//  CookieOptionsUtils.swift
//  VidLoader
//
//  Created by Emmanouil Nicolas on 10/05/22.
//  Copyright © 2022 Petre. All rights reserved.
//

import AVFoundation

struct CookieOptionsUtils {
    
    static func insertCookieOptionsWith(domain: String?, headers: [String: String]?) {
        guard let domain = domain else { return }
        
        if let headers = headers {
            for key in headers.keys {
                let cookie: [HTTPCookiePropertyKey : Any] = [
                    HTTPCookiePropertyKey.domain: domain,
                    HTTPCookiePropertyKey.path: "/",
                    HTTPCookiePropertyKey.secure: true,
                    HTTPCookiePropertyKey.init("HttpsOnly"): true,
                    HTTPCookiePropertyKey.value: headers[key] ?? "",
                    HTTPCookiePropertyKey.name: key,
                ]
                if let httpCookie = HTTPCookie(properties: cookie) {
                    HTTPCookieStorage.shared.setCookie(httpCookie)
                }
            }
        }
    }
}
