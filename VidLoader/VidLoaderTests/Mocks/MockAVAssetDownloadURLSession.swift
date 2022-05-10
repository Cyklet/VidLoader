//
//  MockAVAssetDownloadURLSession.swift
//  VidLoaderTests
//
//  Created by Petre on 12/9/19.
//  Copyright © 2019 Petre. All rights reserved.
//

import AVFoundation
import Foundation

final class MockAVAssetDownloadURLSession: AVAssetDownloadURLSession {

    convenience init(noUse: Bool? = nil) {
        self.init()
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
