//
//  MockAVAssetDownloadURLSession.swift
//  VidLoaderTests
//
//  Created by Petre on 12/9/19.
//  Copyright © 2019 Petre. All rights reserved.
//

import AVFoundation

final class MockAVAssetDownloadURLSession: AVAssetDownloadURLSession {

    init(noUse: Bool? = nil) {}
    
    var getAllTaskFunCheck = EmptyFuncCheck()
    var getAllTasksStub: [MockAVAssetDownloadTask] = []
    override func getAllTasks(completionHandler: @escaping ([URLSessionTask]) -> Void) {
        getAllTaskFunCheck.call()
        completionHandler(getAllTasksStub)
    }
    
    var makeAssetDownloadTaskFunCheck = FuncCheck<String>()
    var makeAssetDownloadTaskStub: MockAVAssetDownloadTask?
    override func makeAssetDownloadTask(asset URLAsset: AVURLAsset,
                                        assetTitle title: String,
                                        assetArtworkData artworkData: Data?,
                                        options: [String : Any]? = nil) -> AVAssetDownloadTask? {
        makeAssetDownloadTaskFunCheck.call(title)
        return makeAssetDownloadTaskStub
    }
}
