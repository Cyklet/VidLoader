//
//  URLSessionTaskExtensions.swift
//  VidLoader
//
//  Created by Petre on 01.09.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import Foundation

extension URLSessionTask {
    var item: ItemInformation? {
        guard let data = taskDescription?.data else { return nil }

        return try? JSONDecoder().decode(ItemInformation.self, from: data)
    }

    var hasFailed: Bool {
        guard let state = item?.state else { return false }
        switch state {
        case .failed: return  true
        case .keyLoaded, .canceled, .completed, .prefetching,
             .running, .unknown, .waiting,
             .noConnection, .paused: return false
        }
    }

    func update(progress: Double, downloadedBytes: Int64) {
        let bytes = Int(exactly: downloadedBytes) ?? .max
        item
            ?|> ItemInformation._progress .~ progress
            ?|> ItemInformation._downloadedBytes .~ bytes
            ?|> save
    }

    func update(location: URL) {
        item
            ?|> ItemInformation._path .~ location.relativePath
            ?|> save
    }

    func update(state: DownloadState) {
        item
            ?|> ItemInformation._state .~ state
            ?|> save
    }

    func save(item: ItemInformation) {
        taskDescription = (try? JSONEncoder().encode(item))?.string
    }
}
