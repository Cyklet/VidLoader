//
//  AVAssetResourceLoadingRequestExtensions.swift
//  VidLoaderTests
//
//  Created by Petre on 12/9/19.
//  Copyright © 2019 Petre. All rights reserved.
//

import AVFoundation

private enum RequestInfoKey: String {
    case headers = "RequestInfoHTTPHeaders"
    case isRenewalRequest = "RequestInfoIsRenewalRequest"
    case isStopSupported = "RequestInfoIsSecureStopSupported"
    case infoURL = "RequestInfoURL"
}

extension AVAssetResourceLoadingRequest {
    static var setupAssociationKey: NSInteger = 0
    var setupFuncDidCall: Bool? {
        get {
            let number = objc_getAssociatedObject(self, &AVAssetResourceLoadingRequest.setupAssociationKey) as? NSNumber
            return number?.boolValue
        }
        set(newValue) {
            let number: NSNumber? = newValue.flatMap(NSNumber.init(booleanLiteral:))
            objc_setAssociatedObject(self, &AVAssetResourceLoadingRequest.setupAssociationKey, number, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    @objc func mockedSetup(response: URLResponse, data: Data) {
        setupFuncDidCall = true
    }

    static func mocked(with resourceLoader: AVAssetResourceLoader = .mocked(),
                       requestInfo: NSDictionary = mockedRequestInfo(),
                       requestID: Int = 1) -> AVAssetResourceLoadingRequest {
        let finalSelector = Selector(("initWithResourceLoader:requestInfo:requestID:"))
        let initialSelector = #selector(NSObject.init)
        let initialInit = class_getInstanceMethod(self, initialSelector)!
        let finalInit = class_getInstanceMethod(self, finalSelector)!
        let finalInitImpl = method_getImplementation(finalInit)
        typealias FinalInit = @convention(c) (AnyObject, Selector, AVAssetResourceLoader, NSDictionary, Int) -> AVAssetResourceLoadingRequest
        typealias InitialInit = @convention(block) (AnyObject, Selector) -> AVAssetResourceLoadingRequest
        let finalBlockInit = unsafeBitCast(finalInitImpl, to: FinalInit.self)
        var request: AVAssetResourceLoadingRequest!
        let newBlock: InitialInit = { obj, sel in
            request = finalBlockInit(obj, finalSelector, resourceLoader, requestInfo, requestID)
            swizzle(className: self,
                    original: #selector(setup(response:data:)),
                    new: #selector(mockedSetup(response:data:)))
            return request
        }
        method_setImplementation(initialInit, imp_implementationWithBlock(newBlock))
        let newSelector = Selector(("new"))
        perform(newSelector)

        return request
    }

    static func mockedRequestInfo(headers: NSDictionary = mockedHeaders,
                                  isRenewalRequest: Int = 0,
                                  isStopSupported: Int = 1,
                                  infoURL: URL = .mocked()) -> NSDictionary {
        return [RequestInfoKey.headers.rawValue: headers,
                RequestInfoKey.isRenewalRequest.rawValue: isRenewalRequest,
                RequestInfoKey.isStopSupported.rawValue: isStopSupported,
                RequestInfoKey.infoURL.rawValue: infoURL]
    }

    private static var mockedHeaders: NSDictionary {
        return ["Accept-Encoding": "gzip", "User-Agent": "1", "X-Playback-Session-Id": "1"]
    }
}
