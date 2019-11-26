//
//  URLSessionTaskExtensions.swift
//  VidLoader
//
//  Created by Petre on 01.09.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import Foundation

extension URLSessionTask {
    var asset: ItemInformation? {
        guard let data = taskDescription?.data else { return nil }

        return try? JSONDecoder().decode(ItemInformation.self, from: data)
    }

    var hasFailed: Bool {
        guard let state = asset?.state else { return false }
        switch state {
        case .failed: return  true
        case .assetInfoLoaded, .canceled, .completed, .prefetching,
             .running, .unknown, .waiting,
             .suspended: return false
        }
    }

    func update(progress: Double, downloadedBytes: Int64) {
        let bytes = Double(Int(exactly: downloadedBytes) ?? .max)
        asset
            ?|> ItemInformation._progress .~ progress
            ?|> ItemInformation._downloadedBytes .~ bytes
            ?|> saveAsset
    }

    func update(location: URL) {
        asset
            ?|> ItemInformation._path .~ location.relativePath
            ?|> saveAsset
    }

    func update(state: DownloadState) {
        asset
            ?|> ItemInformation._state .~ state
            ?|> saveAsset
    }

    func saveAsset(_ asset: ItemInformation) {
        taskDescription = (try? JSONEncoder().encode(asset))?.string
    }
}
