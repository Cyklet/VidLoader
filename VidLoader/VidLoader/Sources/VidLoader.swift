//
//  VidLoader.swift
//  VidLoader
//
//  Created by Petre on 01.09.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import AVFoundation

typealias Completion<T> = (T) -> Void

public protocol VidLoadable {

    /// Add observer that will be called when the state of an item will change
    /// - Parameter observer: Video observer that has state changed as a closure
    func observe(with observer: VidObserver?)

    /// Remove observer from observers list
    func remove(observer: VidObserver?)

    /// Call this method to start item download
    /// - Parameters:
    ///   - identifier: Item unique identifier
    ///   - url: Stream URL
    ///   - title: Item title that will be presented in the phone settings
    ///   - artworkData: Item thumbnail that will be presented in the phone settings
    func download(identifier: String, url: URL,
                  title: String, artworkData: Data?)

    /// Call cancel method when download must be stoped
    /// - Parameter identifier: Item unique identifier
    func cancel(identifier: String)

    /// Get current download state of the item, if downloader doesn't have any information about it the state will be unknown
    /// - Parameter identifier: Item unique identifier
    func state(for identifier: String) -> DownloadState

    /// - Parameter location: Location of the downloaded video in the phone library;
    /// Returns AVURLAsset that will provide the encryption key when video player will demand;
    /// The AVAssetResourceLoaderDelegate of the asset will be handled in VidLoader framework.
    func asset(location: URL) -> AVURLAsset?

    /// Cancel all active items that are currently downloading or preparing to download
    func cancelActiveItems()

    /// Enable mobile data download availability, if the user has only mobile data connection download will continue
    func enableMobileDataAccess()

    /// Disable mobile data download availability, if the user has only mobile data connection download will be paused
    func disableMobileDataAccess()
}

public final class VidLoader: VidLoadable {
    /// Current active items that are waiting to be downloaded or started already to download
    private var activeItems = [String: ItemInformation]() {
        didSet {
            resourcesDelegatesHandler.keep(identifiers: Array(activeItems.keys))
        }
    }
    /// AVAssetDownloadURLSession wrapper that handles all the states of the lifecycle of the tasks
    private let session: Session
    /// PlaylistLoader downloads all m3u8 master files from the server before creating a task in the session
    private let playlistLoader: PlaylistLoadable
    /// Maximal concurrent numbers of the active tasks in the session
    private let maxConcurrentDownloads: Int
    /// SchemeHandler is storage with schemes that are used to parse m3u8 and generate final AVURLAsset
    private let schemeHandler: SchemeHandleable
    /// ResourcesDelegatesHandler stores all active AVAssetResourceLoaderDelegate, if a download has finished, the delegate will be removed from the handler
    private let resourcesDelegatesHandler: ResourcesDelegatesHandleable
    /// Network handles the internet connection changes, if the user doesn't have access to internet or mobile data is disable,
    /// all task will be paused until the internet will reappear. Used to avoid multiple fails of downloads in case of unstable internet connection.
    private let network: Network
    /// FileHandler is used to remove the content in case of download failing or cancelling
    private let fileHandler: FileHandleable
    /// KeyLoader is used to provide the encryption key on video player demand
    private let keyLoader: KeyLoadable
    /// ObserversHandler is used to remove / append observers from the client side
    private let observersHandler: ObserversHandleable

    public convenience init(isMobileDataEnabled: Bool = true,
                            maxConcurrentDownloads: Int = 3) {
        self.init(isMobileDataAccessEnabled: isMobileDataEnabled, maxConcurrentDownloads: maxConcurrentDownloads)
    }

    init(isMobileDataAccessEnabled: Bool,
         maxConcurrentDownloads: Int,
         session: Session = DownloadSession.init(),
         playlistLoader: PlaylistLoadable = PlaylistLoader.init(),
         network: Network = NetworkHandler.init(),
         schemeHandler: SchemeHandleable = SchemeHandler.init(),
         resourcesDelegatesHandler: ResourcesDelegatesHandleable = ResourcesDelegatesHandler.init(),
         fileHandler: FileHandleable = FileHandler.init(),
         keyLoader: KeyLoadable = KeyLoader.init(),
         observersHandler: ObserversHandleable = ObserversHandler.init()) {
        self.maxConcurrentDownloads = maxConcurrentDownloads
        self.session = session
        self.playlistLoader = playlistLoader
        self.network = network
        self.schemeHandler = schemeHandler
        self.resourcesDelegatesHandler = resourcesDelegatesHandler
        self.fileHandler = fileHandler
        self.keyLoader = keyLoader
        self.observersHandler = observersHandler
        setup(isMobileDataAccessEnabled: isMobileDataAccessEnabled)
    }

    public func observe(with observer: VidObserver?) {
        observersHandler.add(observer)
    }

    public func remove(observer: VidObserver?) {
        observersHandler.remove(observer)
    }

    public func download(identifier: String, url: URL, title: String, artworkData: Data?) {
        guard activeItems[identifier] == nil else { return }
        let item = ItemInformation(identifier: identifier,
                                   title: title.removingIllegalCharacters,
                                   mediaLink: url.absoluteString,
                                   state: .unknown,
                                   artworkData: artworkData)
        activeItems[identifier] = item
        handle(event: .prefetching, activeItem: item)
        session.task(identifier: identifier, completion: { [weak self] task in
            guard task == nil else { return }
            self?.requestPlaylist(for: item, url: url)
        })
    }
            

    public func cancel(identifier: String) {
        playlistLoader.cancel(identifier: identifier)
        session.cancelTask(identifier: identifier,
                           hasNotFound: { [weak self] in
                            guard let self = self, let item = self.activeItems[identifier] else { return }
                            self.handle(event: .canceled, activeItem: item)
        })
    }

    public func state(for identifier: String) -> DownloadState {
        guard let item = activeItems[identifier] else { return .unknown }
        return item.state
    }

    public func asset(location: URL) -> AVURLAsset? {
        let urlAsset = AVURLAsset(url: location)
        urlAsset.resourceLoader.setDelegate(keyLoader, queue: keyLoader.queue)
        urlAsset.resourceLoader.preloadsEligibleContentKeys = true

        return urlAsset
    }

    public func cancelActiveItems() {
        activeItems.keys.forEach(cancel)
    }

    public func enableMobileDataAccess() {
        network.enableMobileDataAccess()
    }

    public func disableMobileDataAccess() {
        network.disableMobileDataAccess()
    }

    // MARK: - Private Functions

    private func setup(isMobileDataAccessEnabled: Bool) {
        isMobileDataAccessEnabled ? network.enableMobileDataAccess() : network.disableMobileDataAccess()
        session.setup(injectedSession: nil, stateChanged: { [weak self] event, item in
            self?.handle(event: event, activeItem: item)
        })
        session.allTasks(completion: { [weak self] allTasks in
            let items = allTasks.compactMap { task -> (String, ItemInformation)? in
                guard let item = task.item else { return nil }
                return (item.identifier, item)
            }
            self?.activeItems = Dictionary(items, uniquingKeysWith: { $1 })
        })
        network.setup(networkChanged: { [weak self] state in
            switch state {
            case .available: self?.session.resumeAllTasks()
            case .unavailable: self?.session.suspendAllTasks()
            }
        })
    }

    private func handle(event: DownloadState, activeItem: ItemInformation) {
        guard activeItems[activeItem.identifier] != nil else { return }
        let newItem = activeItem |> ItemInformation._state .~ event
        observersHandler.fire(for: .all, with: newItem)
        observersHandler.fire(for: .single(activeItem.identifier), with: newItem)
        switch event {
        case .completed:
            handleCompletion(for: newItem)
            startNewTaskIfNeeded()
        case .failed, .unknown, .canceled:
            remove(item: newItem)
            startNewTaskIfNeeded()
        case .keyLoaded:
            activeItems[activeItem.identifier] = newItem
            startNewTaskIfNeeded()
        case .prefetching, .running, .suspended, .waiting:
            activeItems[activeItem.identifier] = newItem
        }
    }

    private func handleCompletion(for item: ItemInformation) {
        activeItems[item.identifier] = nil
    }

    private func remove(item: ItemInformation) {
        activeItems[item.identifier] = nil
        fileHandler.deleteContent(for: item)
    }

    private func requestPlaylist(for item: ItemInformation, url: URL) {
        let handleResult: Completion<Result<Void, Error>> = { [weak self] result in
            switch result {
            case .success:
                self?.handle(event: .waiting, activeItem: item)
                self?.startNewTaskIfNeeded()
            case .failure(let error):
                self?.handle(event: .failed(error: .init(error: error)), activeItem: item)
            }
        }
        playlistLoader.load(identifier: item.identifier, at: url, completion: handleResult)
    }

    private func startNewTaskIfNeeded() {
        if activeItems.filter({ $1.inProgress }).count >= maxConcurrentDownloads { return }
        guard let streamResource = playlistLoader.nextStreamResource,
            let item = activeItems[streamResource.0],
            let url = URL(string: item.mediaLink) else { return }
        switch schemeHandler.urlAsset(with: url) {
        case .success(let urlAsset):
            startTask(urlAsset: urlAsset, streamResource: streamResource.1, item: item)
        case .failure(let error):
            handle(event: .failed(error: .init(error: error)), activeItem: item)
        }
    }

    private func startTask(urlAsset: AVURLAsset, streamResource: StreamResource, item: ItemInformation) {
        guard let task = session.addNewTask(urlAsset: urlAsset, for: item) else {
            return
        }
        setupResourceDelegate(item: item, task: task, streamResource: streamResource)
        task.resume()
    }

    func setupResourceDelegate(item: ItemInformation,
                               task: AVAssetDownloadTask,
                               streamResource: StreamResource) {
        let keyDidLoad: () -> Void = { [weak self] in
            guard let upToDateItem = task.item else { return }
            self?.session.sendKeyLoaded(item: upToDateItem)
        }
        let taskDidFail: (Error) -> Void = { [weak self] error in
            self?.handle(event: .failed(error: .init(error: error)), activeItem: item)
        }
        let observer = ResourceLoaderObserver(taskDidFail: taskDidFail, keyDidLoad: keyDidLoad)
        let resourceLoader = ResourceLoader(observer: observer, streamResource: streamResource)
        task.urlAsset.resourceLoader.setDelegate(resourceLoader, queue: resourceLoader.queue)
        task.urlAsset.resourceLoader.preloadsEligibleContentKeys = true
        resourcesDelegatesHandler.add(identifier: item.identifier, loader: resourceLoader)
    }
}
