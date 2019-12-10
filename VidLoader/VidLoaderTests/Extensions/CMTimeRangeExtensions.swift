//
//  CMTimeRangeExtensions.swift
//  VidLoaderTests
//
//  Created by Petre on 12/10/19.
//  Copyright © 2019 Petre. All rights reserved.
//

import AVFoundation

extension CMTimeRange {
    static func mock(start: CMTime = .mock(), duration: CMTime = .mock()) -> CMTimeRange {
        return CMTimeRangeMake(start: start, duration: duration)
    }
}

extension NSValue {
    static func mock(timeRange: CMTimeRange = .mock()) -> NSValue {
        return NSValue(timeRange: timeRange)
    }
}

extension CMTime {
    static func mock(seconds: Double = 0, scale: CMTimeScale = 0) -> CMTime {
        return CMTime(seconds: seconds, preferredTimescale: scale)
    }
}
