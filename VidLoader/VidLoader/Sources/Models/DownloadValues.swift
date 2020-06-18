//
//  DownloadValues.swift
//  VidLoader
//
//  Created by Petre on 6/18/20.
//  Copyright © 2020 Petre. All rights reserved.
//

public struct DownloadValues {
    let identifier: String
    let url: URL
    let title: String
    let artworkData: Data?
    let minRequiredBitrate: Int?
    
    /// - Parameters:
    ///   - identifier: Item unique identifier
    ///   - url: Stream URL
    ///   - title: Item title that will be presented in the phone settings
    ///   - artworkData: Item thumbnail that will be presented in the phone settings
    ///   - minRequiredBitrate: Lowest media bitrate to be used that is greater than or equal to this value, bits per second.  If nil then the highest media bitrate will be selected by default.
    public init(identifier: String, url: URL, title: String, artworkData: Data? = nil, minRequiredBitrate: Int? = nil) {
        self.identifier = identifier
        self.url = url
        self.title = title
        self.artworkData = artworkData
        self.minRequiredBitrate = minRequiredBitrate
    }
}
