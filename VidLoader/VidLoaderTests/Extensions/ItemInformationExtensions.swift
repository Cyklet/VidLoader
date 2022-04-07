//
//  ItemInformationExtensions.swift
//  VidLoaderTests
//
//  Created by Petre on 12/6/19.
//  Copyright © 2019 Petre. All rights reserved.
//

@testable import VidLoader
import Foundation

extension ItemInformation {
    static func mock(identifier: String = "", title: String? = nil, path: String? = nil,
                     mediaLink: String = "", progress: Double = 0, state: DownloadState = .unknown,
                     downloadedBytes: Int = 0, artworkData: Data? = nil, minRequiredBitrate: Int? = nil) -> ItemInformation {
        return ItemInformation(identifier: identifier, title: title, path: path,
                               mediaLink: mediaLink, progress: progress, state: state,
                               downloadedBytes: downloadedBytes, artworkData: artworkData, minRequiredBitrate: minRequiredBitrate)
    }
}
