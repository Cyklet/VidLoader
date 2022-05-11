//
//  MockAVAssetDownloadURLSession.swift
//  VidLoaderTests
//
//  Created by Petre on 12/9/19.
//  Copyright © 2019 Petre. All rights reserved.
//

import AVFoundation
import Foundation

extension MockAVAssetDownloadURLSession {
    static func mock(shouldSwizzle: Bool = true) -> MockAVAssetDownloadURLSession {
        let finalSelector = Selector.defaultInit
        let initialSelector = #selector(NSObject.init)
        let initialInit = class_getInstanceMethod(self, initialSelector)!
        let finalInit = class_getInstanceMethod(self, finalSelector)!
        let finalInitImpl = method_getImplementation(finalInit)
        typealias FinalInit = @convention(c) (AnyObject, Selector) -> MockAVAssetDownloadURLSession
        typealias InitialInit = @convention(block) (AnyObject, Selector) -> MockAVAssetDownloadURLSession
        let finalBlockInit = unsafeBitCast(finalInitImpl, to: FinalInit.self)
        var session: MockAVAssetDownloadURLSession!
        let newBlock: InitialInit = { obj, sel in
            session = finalBlockInit(obj, finalSelector)
            return session
        }
        method_setImplementation(initialInit, imp_implementationWithBlock(newBlock))
        perform(Selector.defaultNew)
        session.mockSetup()
        
        return session
    }
}

final class MockAVAssetDownloadURLSession: AVAssetDownloadURLSession {
    // Swizzled initialization doesn't setup initial state of properties
    func mockSetup() {
        getAllTaskFuncCheck = .init()
        getAllTasksStub = []
        makeAssetDownloadTaskFuncCheck = .init()
    }

    var getAllTaskFuncCheck = EmptyFuncCheck()
    var getAllTasksStub: [MockAVAssetDownloadTask] = []
    override func getAllTasks(completionHandler: @escaping ([URLSessionTask]) -> Void) {
        getAllTaskFuncCheck.call()
        completionHandler(getAllTasksStub)
    }
    
    var makeAssetDownloadTaskFuncCheck = FuncCheck<String>()
    var makeAssetDownloadTaskStub: MockAVAssetDownloadTask?
    override func makeAssetDownloadTask(asset URLAsset: AVURLAsset,
                                        assetTitle title: String,
                                        assetArtworkData artworkData: Data?,
                                        options: [String : Any]? = nil) -> AVAssetDownloadTask? {
        makeAssetDownloadTaskFuncCheck.call(title)
        return makeAssetDownloadTaskStub
    }
}
