//
//  DownloadValuesExtensions.swift
//  VidLoaderTests
//
//  Created by Petre on 6/18/20.
//  Copyright © 2020 Petre. All rights reserved.
//
@testable import VidLoader
import Foundation

extension DownloadValues {
    static func mock(identifier: String = "persitent_identifier", url: URL = .mock(),
                     title: String = "", artworkData: Data? = nil,
                     minRequiredBitrate: Int? = nil) -> DownloadValues {
        return DownloadValues(identifier: identifier, url: url,
                              title: title, artworkData: artworkData,
                              minRequiredBitrate: minRequiredBitrate)
    }
}
