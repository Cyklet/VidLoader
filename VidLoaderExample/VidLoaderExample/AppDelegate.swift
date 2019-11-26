//
//  AppDelegate.swift
//  VidLoaderExample
//
//  Created by Petre on 10/14/19.
//  Copyright © 2019 Petre. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        window = defaultWindow

        return true
    }

    // MARK: - Private functions

    private var defaultWindow: UIWindow {
        let window = UIWindow()
        window.backgroundColor = .clear
        window.rootViewController = VideoListBuilder.create()
        window.makeKeyAndVisible()

        return window
    }
}

