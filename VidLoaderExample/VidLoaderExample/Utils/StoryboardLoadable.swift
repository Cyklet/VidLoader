//
//  StoryboardLoadable.swift
//  VidLoaderExample
//
//  Created by Petre on 01.11.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import UIKit

protocol StoryboardLoadable { }

extension StoryboardLoadable where Self: UIViewController {
    static var storyboardName: String {
        return String(describing: Self.self)
    }

    static func createFromStoryboard(name: String = Self.storyboardName) -> Self {
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle(for: self))
        guard let controller = storyboard.instantiateInitialViewController() as? Self else {
            fatalError("Initial view controller in storyboard \(storyboard) is other class")
        }
        return controller
    }
}
