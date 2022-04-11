//
//  DownloadValues.swift
//  VidLoader
//
//  Created by Petre on 6/18/20.
//  Copyright © 2020 Petre. All rights reserved.
//
import Foundation

public struct DownloadValues {
    let identifier: String
    let url: URL
    let title: String
    let artworkData: Data?
    let minRequiredBitrate: Int?
    let headers: [String: String]?
    
    /// - Parameters:
    ///   - identifier: Item's unique identifier
    ///   - url: Stream URL
    ///   - title: Item's title that will be presented in the phone settings
    ///   - artworkData: Item's optional thumbnail that will be presented in the phone settings
    ///   - minRequiredBitrate: Lowest media bitrate to be used that is greater than or equal to this value, bits per second. If it's nil, then the highest media bitrate will be selected by default.
    ///   - headers: HTTPHeader to be used when headers is necessary to download m3u8 or key files
    public init(identifier: String, url: URL, title: String, artworkData: Data? = nil, minRequiredBitrate: Int? = nil, headers: [String: String]? = nil) {
        self.identifier = identifier
        self.url = url
        self.title = title
        self.artworkData = artworkData
        self.minRequiredBitrate = minRequiredBitrate
        self.headers = headers
    }
}
