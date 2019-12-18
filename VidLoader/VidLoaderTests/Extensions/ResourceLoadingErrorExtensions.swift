//
//  ResourceLoadingErrorExtensions.swift
//  VidLoaderTests
//
//  Created by Petre on 12/6/19.
//  Copyright © 2019 Petre. All rights reserved.
//

@testable import VidLoader

extension ResourceLoadingError: Equatable {
    public static func == (lhs: ResourceLoadingError, rhs: ResourceLoadingError) -> Bool {
        switch (lhs, rhs) {
        case (.unknown, unknown), (.urlScheme, .urlScheme), (.m3u8, .m3u8), (.custom, .custom):
            return true
        default:
            return false
        }
    }
}
