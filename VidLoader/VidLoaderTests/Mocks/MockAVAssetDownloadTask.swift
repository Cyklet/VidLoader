//
//  MockAVAssetDownloadTask.swift
//  VidLoaderTests
//
//  Created by Petre on 12/9/19.
//  Copyright © 2019 Petre. All rights reserved.
//

import AVFoundation

final class MockAVAssetDownloadTask: AVAssetDownloadTask {

    init(noUse: Bool? = nil) {}
    
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
