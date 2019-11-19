//
//  VideoListDataProvider.swift
//  VidLoaderExample
//
//  Created by Petre on 14.10.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

protocol VideoListDataProviding {
    var items: [VideoData] { get }
    func setupActions(showRemoveActionSheet: @escaping (VideoData) -> Void,
                      showStopActionSheet: @escaping (VideoData) -> Void,
                      showFailedActionSheet: @escaping (VideoData) -> Void,
                      reloadData: @escaping () -> Void)
    func urlAsset(row: Int) -> AVURLAsset?
    func videoModel(row: Int) -> VideoCellModel
    func deleteVideo(with data: VideoData)
    func startDownload(with data: VideoData)
    func stopDownload(with data: VideoData)
}

final class VideoListDataProvider: VideoListDataProviding {
    private let userDefaults: UserDefaults
    private let itemsKey: String
    private let vidLoaderHandler: VidLoaderHandler
    private let fileManager: FileManager
    private(set) var items: [VideoData] = []
    private var showRemoveActionSheet: ((VideoData) -> Void)?
    private var showStopActionSheet: ((VideoData) -> Void)?
    private var showFailedActionSheet: ((VideoData) -> Void)?
    private var reloadData: (() -> Void)?
    private var observer: VidObserver?

    init(userDefaults: UserDefaults = .standard,
         itemsKey: String = "vid_loader_example_items",
         vidLoaderHandler: VidLoaderHandler = .shared,
         fileManager: FileManager = .default) {
        self.userDefaults = userDefaults
        self.itemsKey = itemsKey
        self.vidLoaderHandler = vidLoaderHandler
        self.fileManager = fileManager
        self.items = extractItems(itemsKey: itemsKey)
        self.observer = VidObserver(type: .all, stateChanged: { [weak self] item in
            self?.update(item: item)
        })
        setupObservers()
    }

    func setupActions(showRemoveActionSheet: @escaping (VideoData) -> Void,
                      showStopActionSheet: @escaping (VideoData) -> Void,
                      showFailedActionSheet: @escaping (VideoData) -> Void,
                      reloadData: @escaping () -> Void) {
        self.showRemoveActionSheet = showRemoveActionSheet
        self.showStopActionSheet = showStopActionSheet
        self.showFailedActionSheet = showFailedActionSheet
        self.reloadData = reloadData
    }

    func urlAsset(row: Int) -> AVURLAsset? {
        guard let location = items[row].location else { return nil }
        return vidLoaderHandler.loader.asset(location: location)
    }

    func videoModel(row: Int) -> VideoCellModel {
        let videoData = items[row]
        let actions = VideoCellActions(
            deleteVideo: { [weak self] in self?.showRemoveActionSheet?(videoData) },
            cancelDownload: { [weak self] in self?.showStopActionSheet?(videoData) },
            startDownload: { [weak self] in self?.startDownload(with: videoData) },
            resumeFailedVideo: { [weak self] in self?.showFailedActionSheet?(videoData) }
        )

        return VideoCellModel(identifier: videoData.identifier, title: videoData.title,
                              thumbnailName: videoData.imageName, state: videoData.state,
                              actions: actions)
    }

    func deleteVideo(with data: VideoData) {
        removeVideo(identifier: data.identifier, location: data.location, state: .unknown)
    }
    
    func startDownload(with data: VideoData) {
        guard let url = URL(string: data.stringURL) else { return }
        vidLoaderHandler.loader.download(identifier: data.identifier,
                                         url: url,
                                         title: data.title,
                                         artworkData: UIImage(named: data.imageName)?.jpegData(compressionQuality: 1))
    }
    
    func stopDownload(with data: VideoData) {
        guard vidLoaderHandler.loader.state(for: data.identifier) != .unknown else {
            removeVideo(identifier: data.identifier, location: nil, state: .unknown)
            reloadData?()
            return
        }
        vidLoaderHandler.loader.cancel(identifier: data.identifier)
    }

    // MARK: - Private functions

    private func update(item: ItemInformation) {
        guard let index = items.firstIndex(where: { $0.identifier == item.identifier }) else { return }
        let videoData = items[index]
        items[index] = VideoData(identifier: videoData.identifier, title: videoData.title,
                                 imageName: videoData.imageName, state: item.state,
                                 stringURL: videoData.stringURL, location: item.location)
        save(items: items)
    }

    private func removeVideo(identifier: String, location: URL?, state: DownloadState) {
        guard let index = items.firstIndex(where: { $0.identifier == identifier }) else { return }
        let data = items[index]
        if let location = location ?? data.location { try? fileManager.removeItem(at: location) }
        let videoData = VideoData(identifier: data.identifier, title: data.title,
                                  imageName: data.imageName, state: state,
                                  stringURL: data.stringURL)
        items[index] = videoData
        save(items: items)
    }

    private func setupObservers() {
        observer = VidObserver(type: .all, stateChanged: { [weak self] item in
            self?.update(item: item)
        })
        vidLoaderHandler.loader.observe(with: observer)
    }

    private func extractItems(itemsKey: String) -> [VideoData] {
        guard let data = userDefaults.value(forKey: itemsKey) as? Data,
            let items = try? JSONDecoder().decode([VideoData].self, from: data) else {
                let items = generateDefaultItems()
                save(items: items)
                return items
        }
        return items
    }

    private func save(items: [VideoData]) {
        guard let data = try? JSONEncoder().encode(items) else { return }
        userDefaults.set(data, forKey: itemsKey)
    }

    private func generateDefaultItems() -> [VideoData] {
        let defaultURL = ""

        return [VideoData(identifier: "id_1", title: "Item 1", stringURL: defaultURL),
                VideoData(identifier: "id_2", title: "Item 2", stringURL: defaultURL),
                VideoData(identifier: "id_3", title: "Item 3", stringURL: defaultURL),
                VideoData(identifier: "id_4", title: "Item 4", stringURL: defaultURL),
                VideoData(identifier: "id_5", title: "Item 5", stringURL: defaultURL),
                VideoData(identifier: "id_6", title: "Item 6", stringURL: defaultURL),
                VideoData(identifier: "id_7", title: "Item 7", stringURL: defaultURL),
                VideoData(identifier: "id_8", title: "Item 8", stringURL: defaultURL)]
    }
}
