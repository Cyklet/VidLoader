//
//  DownloadSession.swift
//  VidLoader
//
//  Created by Petre on 01.09.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import AVFoundation

protocol Session {
    func allTasks(completion: Completion<[AVAssetDownloadTask]>?)
    func task(identifier: String, completion: Completion<AVAssetDownloadTask?>?)
    func addNewTask(urlAsset: AVURLAsset, for item: ItemInformation) -> AVAssetDownloadTask?
    func cancelTask(identifier: String, hasNotFound: @escaping () -> Void)
    func sendKeyLoaded(item: ItemInformation)
    func suspendTask(identifier: String)
    func resumeTask(identifier: String)
    func suspendAllTasks()
    func resumeAllTasks()
    func setup(injectedSession: AVAssetDownloadURLSession?, stateChanged: ((DownloadState, ItemInformation) -> Void)?)
}

final class DownloadSession: NSObject {
    private var injectedSession: AVAssetDownloadURLSession?
    private var stateChanged: ((DownloadState, ItemInformation) -> Void)?

    func setup(injectedSession: AVAssetDownloadURLSession?,
               stateChanged: ((DownloadState, ItemInformation) -> Void)?) {
        self.injectedSession = injectedSession
        self.stateChanged = stateChanged
    }

    // MARK: - Private
    
    // Session is a lazy var property, it will be initialized when `get all tasks` will be called in the
    // vidloader class, before this session observables also must be set. If this object is created in the `init` of the
    // main class, then we will lose all calls that are coming between application starts and observable was set.
    private lazy var session: AVAssetDownloadURLSession = {
        return injectedSession ?? AVAssetDownloadURLSession(configuration: self.configuration,
                                                            assetDownloadDelegate: self,
                                                            delegateQueue: .main)
    }()

    private var configuration: URLSessionConfiguration {
        return .background(withIdentifier: "vidloader_session_configuration")
    }

    /// The `didFinishDownloadingTo` method is called in many cases, we need to check asset state
    fileprivate func handleDownloadState(item: ItemInformation, task: AVAssetDownloadTask) {
        // When task was cancelled `didFinishDownloadingTo` delegate is calling
        // with completed state. `isCancelled` state is set in `cancelTask` function
        // and saved in task description. Also we need to handle cancelation here because
        // we need video location that is coming in `didFinishDownloadingTo`
        if task.error == nil || item.isCancelled {
            sendCompleteState(item: item)

            return
        }
        let newItem = item |> ItemInformation._state .~ .failed(error: .init(error: task.error))
        task.save(item: newItem)
        sendCompleteState(item: newItem)
    }

    fileprivate func sendCompleteState(item: ItemInformation) {
        switch item.state {
        case .failed(let error):
            stateChanged?(.failed(error: error), item)
        case .canceled:
            stateChanged?(.canceled, item)
        default:
            stateChanged?(.completed, item)
        }
    }
}

extension DownloadSession: Session {
    func task(identifier: String, completion: Completion<AVAssetDownloadTask?>?) {
        allTasks { tasks in
            let task = tasks.first(where: { $0.item?.identifier == identifier })
            completion?(task)
        }
    }

    func allTasks(completion: Completion<[AVAssetDownloadTask]>?) {
        session.getAllTasks { completion?($0.compactMap { $0 as? AVAssetDownloadTask }) }
    }

    func addNewTask(urlAsset: AVURLAsset, for item: ItemInformation) -> AVAssetDownloadTask? {
        let task = session.makeAssetDownloadTask(asset: urlAsset,
                                                 assetTitle: item.title ?? "",
                                                 assetArtworkData: item.artworkData,
                                                 options: item.options)
        guard let downloadTask = task else {
            stateChanged?(.failed(error: .taskNotCreated), item)
            return nil
        }
        downloadTask.save(item: item)
        stateChanged?(item.state, item)

        return downloadTask
    }

    /// Event `onCancel` will be called in `handleDownloadState` after task will be invalidate
    func cancelTask(identifier: String, hasNotFound: @escaping () -> Void) {
        task(identifier: identifier) { task in
            guard let task = task else {
                return hasNotFound()
            }
            task.update(state: .canceled)
            task.cancel()
        }
    }

    func suspendTask(identifier: String) {
        task(identifier: identifier) { [weak self] task in
            guard let task = task, let item = task.item else {
                return
            }
            let newItem = item |> ItemInformation._state .~ .paused(item.progress)
            task.save(item: newItem)
            self?.stateChanged?(newItem.state, newItem)
            task.suspend()
        }
    }

    func suspendAllTasks() {
        allTasks {
            $0.forEach {
                if $0.item?.isPaused == true { return }
                $0.suspend()
            }
        }
    }

    func resumeTask(identifier: String) {
        task(identifier: identifier) { [weak self] task in
            guard let task = task, let item = task.item else {
                return
            }
            let newItem = item |> ItemInformation._state .~ .waiting
            task.save(item: newItem)
            self?.stateChanged?(newItem.state, newItem)
            task.resume()
        }
    }

    func resumeAllTasks() {
        allTasks {
            $0.forEach {
                if $0.item?.isPaused == true { return }
                return $0.resume()
            }
        }
    }

    func sendKeyLoaded(item: ItemInformation) {
        task(identifier: item.identifier) { [weak self] task in
            guard let task = task else { return }
            let state: DownloadState = .keyLoaded
            let newItem = item |> ItemInformation._state .~ state
            task.save(item: newItem)
            self?.stateChanged?(state, newItem)
        }
    }
}

extension DownloadSession: AVAssetDownloadDelegate {

    // Even if task has failed we will save asset information as completed in plist
    // `didFinishDownloadingTo` delegate is calling first after this `didCompleteWithError` is also calling
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
        assetDownloadTask.update(location: location)
        guard let item = assetDownloadTask.item else { return }
        switch assetDownloadTask.state {
        case .suspended:
            stateChanged?(.noConnection(item.progress), item)
        // `.canceling` can be thrown when application just launched with active downloads
        case .canceling:
            stateChanged?(.canceled, item)
        case .running, .completed:
            handleDownloadState(item: item, task: assetDownloadTask)
        @unknown default:
            print("Unimplemented cases")
        }
    }

    // We are saving in task description:
    // progress - that is presented in UI of application
    // downloadedBytes - that is used to calculate remaining device storage
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask,
                    didLoad timeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue],
                    timeRangeExpectedToLoad: CMTimeRange) {
        let progress = loadedTimeRanges.reduce(0) { $0 + $1.timeRangeValue.seconds / timeRangeExpectedToLoad.seconds }
        assetDownloadTask.update(progress: min(1, max(0, progress)),
                                 downloadedBytes: assetDownloadTask.countOfBytesReceived)
        guard assetDownloadTask.state == .running, let item = assetDownloadTask.item else { return }
        stateChanged?(.running(progress), item)
    }

    // All main logic is doing in `didFinishDownloadingTo` delegate because
    // `didCompleteWithError` delegate is calling after and doesn't have .movpkg location
    // wasCancelled - is setted in `cancelTask(identifier: String)`
    // hasFailed - is setted in `didFinishDownloadingTo` -> `handleDownloadState`
    // We still need to check `error` in this delegate because on relaunch application
    // `didFinishDownloadingTo` sometimes doesn't have error and fail state is setting here
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        // This is a very strange case, when `didCompleteWithError` is being
        // called after AVAssetDownloadTask.cancel()
        guard let item = task.item else { return }

        guard !item.isCancelled else {
            return
        }
        guard let error = error, !task.hasFailed else { return }
        let state: DownloadState = .failed(error: .custom(VidLoaderError(error: error)))
        stateChanged?(state, item |> ItemInformation._state .~ state)
    }
}
