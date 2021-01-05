//
//  ItemInformation.swift
//  VidLoader
//
//  Created by Petre on 01.09.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import AVFoundation
import Foundation

/// ItemInformation is a stream description that is used and saved in the download task
public struct ItemInformation: Codable, Equatable {
    /// Item unique identifier
    public let identifier: String
    /// The path where the stream was downloaded
    public let path: String?
    /// String url of the stream
    public let mediaLink: String
    /// Current item state
    public let state: DownloadState
    /// Item title that will be presented in the phone settings
    public let title: String?
    /// Current downloaded bytes
    public let downloadedBytes: Int
    /// Item thumbnail that will be presented in the phone settings
    let artworkData: Data?
    /// Current item download progress
    let progress: Double
    /// Tthe lowest media bitrate to be used that is greater than or equal to this value
    /// Value should be used as NSNumber in bits per second. If no suitable media bitrate is found, the highest media bitrate will be selected
    let minRequiredBitrate: Int?
    ///HTTPHeader to be used when headers is necessary to download m3u8 or key files
    let headers: [String: String]?

    init(identifier: String, title: String?, path: String? = nil,
         mediaLink: String = "", progress: Double = 0,
         state: DownloadState, downloadedBytes: Int = 0,
         artworkData: Data?, minRequiredBitrate: Int?,
         headers: [String: String]? = nil) {
        self.identifier = identifier
        self.title = title
        self.path = path
        self.mediaLink = mediaLink
        self.progress = progress
        self.state = state
        self.downloadedBytes = downloadedBytes
        self.artworkData = artworkData
        self.minRequiredBitrate = minRequiredBitrate
        self.headers = headers
    }

    public var location: URL? {
        guard let path = path else { return nil }

        return URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent(path)
    }

    var isReachable: Bool {
        guard let location = location else { return false }

        return (try? location.checkResourceIsReachable()) ?? false
    }

    var inProgress: Bool {
        switch state {
        case .failed, .canceled, .completed, .unknown, .prefetching, .waiting, .paused:
            return false
        case .running, .noConnection, .keyLoaded:
            return true
        }
    }

    var isCancelled: Bool {
        switch state {
        case .canceled:
            return true
        case .keyLoaded, .failed,
             .completed, .paused,
             .running, .unknown, .waiting,
             .noConnection, .prefetching:
            return false
        }
    }
    
    var options: [String: Any]? {
        guard let minRequiredBitrate = minRequiredBitrate else {
            return nil
        }
        return [AVAssetDownloadTaskMinimumRequiredMediaBitrateKey: NSNumber(integerLiteral: minRequiredBitrate)]
    }

    var isPaused: Bool {
        switch state {
        case .paused:
            return true
        case .keyLoaded, .failed,
             .completed, .waiting,
             .running, .unknown,
             .prefetching, .canceled, .noConnection:
            return false
        }
    }
}

extension ItemInformation {
    static let _state = Lens<ItemInformation, DownloadState>(
        get: { $0.state },
        set: { ItemInformation(identifier: $1.identifier, title: $1.title, path: $1.path,
                               mediaLink: $1.mediaLink, progress: $1.progress,
                               state: $0, downloadedBytes: $1.downloadedBytes,
                               artworkData: $1.artworkData, minRequiredBitrate: $1.minRequiredBitrate,
                               headers: $1.headers) }
    )

    static let _path = Lens<ItemInformation, String?>(
        get: { $0.path },
        set: { ItemInformation(identifier: $1.identifier, title: $1.title, path: $0,
                               mediaLink: $1.mediaLink, progress: $1.progress,
                               state: $1.state, downloadedBytes: $1.downloadedBytes,
                               artworkData: $1.artworkData, minRequiredBitrate: $1.minRequiredBitrate,
                               headers: $1.headers) }
    )

    static let _progress = Lens<ItemInformation, Double>(
        get: { $0.progress },
        set: { ItemInformation(identifier: $1.identifier, title: $1.title, path: $1.path,
                               mediaLink: $1.mediaLink, progress: $0,
                               state: $1.state, downloadedBytes: $1.downloadedBytes,
                               artworkData: $1.artworkData, minRequiredBitrate: $1.minRequiredBitrate,
                               headers: $1.headers) }
    )

    static let _downloadedBytes = Lens<ItemInformation, Int>(
        get: { $0.downloadedBytes },
        set: { ItemInformation(identifier: $1.identifier, title: $1.title, path: $1.path,
                               mediaLink: $1.mediaLink, progress: $1.progress,
                               state: $1.state, downloadedBytes: $0,
                               artworkData: $1.artworkData, minRequiredBitrate: $1.minRequiredBitrate,
                               headers: $1.headers) }
    )
}
