//
//  AVAssetResourceLoadingRequestExtensions.swift
//  VidLoaderTests
//
//  Created by Petre on 12/9/19.
//  Copyright © 2019 Petre. All rights reserved.
//

import AVFoundation
@testable import VidLoader

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
            let number: NSNumber? = newValue ?|> NSNumber.init(booleanLiteral:)
            objc_setAssociatedObject(self, &AVAssetResourceLoadingRequest.setupAssociationKey, number, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    @objc func mockSetup(response: URLResponse, data: Data, isEntireLengthAvailableOnDemand: Bool) {
        setupFuncDidCall = true
    }
    
    static var contentInformationRequestAssociationKey: NSInteger = 1
    var contentInformationRequestStub: AVAssetResourceLoadingContentInformationRequest? {
        get {
            let instance = objc_getAssociatedObject(self, &AVAssetResourceLoadingRequest.contentInformationRequestAssociationKey) as? AVAssetResourceLoadingContentInformationRequest
            return instance
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AVAssetResourceLoadingRequest.contentInformationRequestAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    @objc var mockContentInformationRequest: AVAssetResourceLoadingContentInformationRequest? {
        return contentInformationRequestStub
    }
    
    static func mockWithCustomContentInfoRequest(with resourceLoader: AVAssetResourceLoader = .mock(),
                                                 requestInfo: NSDictionary = mockRequestInfo(),
                                                 requestID: Int = 1) -> AVAssetResourceLoadingRequest {
        return create(with: resourceLoader,
                      requestInfo: requestInfo,
                      requestID: requestID,
                      swizzleAction: { swizzle(className: self, original: #selector(getter: contentInformationRequest), new: #selector(getter: mockContentInformationRequest)) })
    }
    
    static func mockWithCustomSetup(with resourceLoader: AVAssetResourceLoader = .mock(),
                                    requestInfo: NSDictionary = mockRequestInfo(),
                                    requestID: Int = 1) -> AVAssetResourceLoadingRequest {
        return create(with: resourceLoader,
                      requestInfo: requestInfo,
                      requestID: requestID,
                      swizzleAction: { swizzle(className: self, original: #selector(setup(response:data:isEntireLengthAvailableOnDemand:)), new: #selector(mockSetup(response:data:isEntireLengthAvailableOnDemand:))) })
    }

    static private func create(with resourceLoader: AVAssetResourceLoader = .mock(),
                               requestInfo: NSDictionary = mockRequestInfo(),
                               requestID: Int = 1,
                               swizzleAction: (() -> Void)?) -> AVAssetResourceLoadingRequest {
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
            swizzleAction?()
            return request
        }
        method_setImplementation(initialInit, imp_implementationWithBlock(newBlock))
        perform(Selector.defaultNew)
        
        return request
    }

    static func mockRequestInfo(headers: NSDictionary = mockHeaders,
                                isRenewalRequest: Int = 0,
                                isStopSupported: Int = 1,
                                infoURL: URL = .mock()) -> NSDictionary {
        return [RequestInfoKey.headers.rawValue: headers,
                RequestInfoKey.isRenewalRequest.rawValue: isRenewalRequest,
                RequestInfoKey.isStopSupported.rawValue: isStopSupported,
                RequestInfoKey.infoURL.rawValue: infoURL]
    }
    
    private static var mockHeaders: NSDictionary {
        return ["Accept-Encoding": "gzip", "User-Agent": "1", "X-Playback-Session-Id": "1"]
    }
}
