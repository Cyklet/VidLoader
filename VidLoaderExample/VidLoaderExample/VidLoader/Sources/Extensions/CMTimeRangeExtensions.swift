//
//  CMTimeRangeExtensions.swift
//  VidLoader
//
//  Created by Petre on 01.09.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import CoreMedia

extension CMTimeRange {
    var seconds: Double {
        return duration.seconds
    }
}
