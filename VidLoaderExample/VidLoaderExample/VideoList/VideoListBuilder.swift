//
//  VideoListBuilder.swift
//  VidLoaderExample
//
//  Created by Petre on 01.11.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import UIKit

struct VideoListBuilder {
    static func create() -> UINavigationController {
        let controller = VideoListController.createFromStoryboard()
        controller.dataProvider = VideoListDataProvider()

        return UINavigationController(rootViewController: controller)
    }
}
