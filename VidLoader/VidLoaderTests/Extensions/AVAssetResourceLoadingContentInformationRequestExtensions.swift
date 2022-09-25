//
//  AVAssetResourceLoadingContentInformationRequestExtensions.swift
//  VidLoaderTests
//
//  Created by Petre Plotnic on 25.09.22.
//  Copyright © 2022 Petre. All rights reserved.
//

import AVFoundation

extension AVAssetResourceLoadingContentInformationRequest {
    
    static func mock(loadingRequest: AVAssetResourceLoadingRequest,
                     allowedContentTypes: NSArray?) -> AVAssetResourceLoadingContentInformationRequest {
        let finalSelector = Selector(("initWithLoadingRequest:allowedContentTypes:"))
        let initialSelector = #selector(NSObject.init)
        let initialInit = class_getInstanceMethod(self, initialSelector)!
        let finalInit = class_getInstanceMethod(self, finalSelector)!
        let finalInitImpl = method_getImplementation(finalInit)
        typealias FinalInit = @convention(c) (AnyObject, Selector, AVAssetResourceLoadingRequest, NSArray?) -> AVAssetResourceLoadingContentInformationRequest
        typealias InitialInit = @convention(block) (AnyObject, Selector) -> AVAssetResourceLoadingContentInformationRequest
        let finalBlockInit = unsafeBitCast(finalInitImpl, to: FinalInit.self)
        var contentInformationRequest: AVAssetResourceLoadingContentInformationRequest!
        let newBlock: InitialInit = { obj, sel in
            contentInformationRequest = finalBlockInit(obj, finalSelector, loadingRequest, allowedContentTypes)
            return contentInformationRequest
        }
        method_setImplementation(initialInit, imp_implementationWithBlock(newBlock))
        perform(Selector.defaultNew)
        
        return contentInformationRequest
    }
}
