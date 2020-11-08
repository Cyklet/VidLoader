//
//  MockSession.swift
//  VidLoaderTests
//
//  Created by Petre on 12/11/19.
//  Copyright © 2019 Petre. All rights reserved.
//
import AVFoundation
@testable import VidLoader

final class MockSession: Session {
    var allTasksFuncCheck = EmptyFuncCheck()
    var allTasksStub: [AVAssetDownloadTask] = []
    func allTasks(completion: Completion<[AVAssetDownloadTask]>?) {
        completion?(allTasksStub)
        allTasksFuncCheck.call()
    }
    
    var taskFuncCheck = FuncCheck<String>()
    var taskStub: MockAVAssetDownloadTask?
    func task(identifier: String, completion: Completion<AVAssetDownloadTask?>?) {
        taskFuncCheck.call(identifier)
        completion?(taskStub)
    }
    
    var addNewTaskFuncCheck = FuncCheck<(AVURLAsset, ItemInformation)>()
    var addNewTaskStub: MockAVAssetDownloadTask?
    func addNewTask(urlAsset: AVURLAsset, for item: ItemInformation) -> AVAssetDownloadTask? {
        addNewTaskFuncCheck.call((urlAsset, item))
        return addNewTaskStub
    }
    
    var cancelTaskFuncCheck = FuncCheck<String>()
    var cancelTaskStub: Bool = false
    func cancelTask(identifier: String, hasNotFound: @escaping () -> Void) {
        cancelTaskFuncCheck.call(identifier)
        if cancelTaskStub { hasNotFound() }
    }
    
    var sendKeyLoadedFuncCheck = FuncCheck<ItemInformation>()
    func sendKeyLoaded(item: ItemInformation) {
        sendKeyLoadedFuncCheck.call(item)
    }
    
    var suspendAllTasksFuncCheck = EmptyFuncCheck()
    func suspendAllTasks() {
        suspendAllTasksFuncCheck.call()
    }
    
    var resumeAllTasksFuncCheck = EmptyFuncCheck()
    func resumeAllTasks() {
        resumeAllTasksFuncCheck.call()
    }
    
    var setupFuncCheck = FuncCheck<AVAssetDownloadURLSession?>()
    var setupStub: ((DownloadState, ItemInformation) -> Void)?
    func setup(injectedSession: AVAssetDownloadURLSession?, stateChanged: ((DownloadState, ItemInformation) -> Void)?) {
        setupFuncCheck.call(injectedSession)
        setupStub = stateChanged
    }

    let resumeTaskFuncCheck = FuncCheck<String>()
    func resumeTask(identifier: String) {
        resumeTaskFuncCheck.call(identifier)
    }

    let suspendTaskFuncCheck = FuncCheck<String>()
    func suspendTask(identifier: String) {
        suspendTaskFuncCheck.call(identifier)
    }
}
