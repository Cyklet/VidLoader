//
//  MockAVAssetDownloadTask.swift
//  VidLoaderTests
//
//  Created by Petre on 12/9/19.
//  Copyright © 2019 Petre. All rights reserved.
//

import AVFoundation

extension MockAVAssetDownloadTask {
    static func mock() -> MockAVAssetDownloadTask {
        let finalSelector = Selector.defaultInit
        let initialSelector = #selector(NSObject.init)
        let initialInit = class_getInstanceMethod(self, initialSelector)!
        let finalInit = class_getInstanceMethod(self, finalSelector)!
        let finalInitImpl = method_getImplementation(finalInit)
        typealias FinalInit = @convention(c) (AnyObject, Selector) -> MockAVAssetDownloadTask
        typealias InitialInit = @convention(block) (AnyObject, Selector) -> MockAVAssetDownloadTask
        let finalBlockInit = unsafeBitCast(finalInitImpl, to: FinalInit.self)
        var task: MockAVAssetDownloadTask!
        let newBlock: InitialInit = { obj, sel in
            task = finalBlockInit(obj, finalSelector)
            return task
        }
        method_setImplementation(initialInit, imp_implementationWithBlock(newBlock))
        perform(Selector.defaultNew)
        task.mockSetup()
        
        return task
    }
}

final class MockAVAssetDownloadTask: AVAssetDownloadTask {
    
    // Swizzled initialization doesn't setup initial state of properties
    func mockSetup() {
        resumeFunc = .init()
        suspendFunc = .init()
        cancelFunc = .init()
        taskDescriptionSetFunc = .init()
        stateStub = .running
        countOfBytesReceivedStub = 0
    }
    
    override var urlAsset: AVURLAsset {
        return .mock()
    }

    var resumeFunc = EmptyFuncCheck()
    override func resume() {
        resumeFunc.call()
    }

    var suspendFunc = EmptyFuncCheck()
    override func suspend() {
        suspendFunc.call()
    }

    var cancelFunc = EmptyFuncCheck()
    override func cancel() {
        cancelFunc.call()
    }

    var taskDescriptionStub: String?
    var taskDescriptionSetFunc = FuncCheck<String?>()
    override var taskDescription: String? {
        get {
            return taskDescriptionStub
        }
        set {
            taskDescriptionSetFunc.call(newValue)
            taskDescriptionStub = newValue
        }
    }

    var stateStub: URLSessionTask.State = .running
    override var state: URLSessionTask.State {
        get {
            return stateStub
        }
        set {
            stateStub = newValue
        }
    }

    var countOfBytesReceivedStub: Int64 = 0
    override var countOfBytesReceived: Int64 {
        get {
            return countOfBytesReceivedStub
        }
        set {
            countOfBytesReceivedStub = newValue
        }
    }

    var errorStub: Error?
    override var error: Error? {
        get {
            return errorStub
        }
        set {
            errorStub = newValue
        }
    }
}
