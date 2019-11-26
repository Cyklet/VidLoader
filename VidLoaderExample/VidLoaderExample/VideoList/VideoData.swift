//
//  VideoData.swift
//  VidLoaderExample
//
//  Created by Petre on 15.10.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import Foundation
import VidLoader

struct VideoData: Codable {
    let identifier: String
    let title: String
    let imageName: String
    let state: DownloadState
    let stringURL: String
    let location: URL?

    init(identifier: String, title: String, imageName: String = "default_thumbnail",
         state: DownloadState = .unknown, stringURL: String, location: URL? = nil) {
        self.identifier = identifier
        self.title = title
        self.imageName = imageName
        self.state = state
        self.stringURL = stringURL
        self.location = location
    }
}
