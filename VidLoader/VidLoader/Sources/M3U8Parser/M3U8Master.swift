//
//  M3U8Master.swift
//  VidLoader
//
//  Created by Petre on 01.09.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import AVFoundation

struct M3U8Master: StreamContentRepresentable {
    // MARK: - StreamContentRepresentable

    func adjust(response: String, completion: @escaping (Result<String, M3U8Error>) -> Void) {
        completion(.success(replaceSchemes(in: response)))
    }

    // MARK: - Private functions

    private func replaceSchemes(in response: String) -> String {
        let suffix = "://"
        return response.replacingOccurrences(of: SchemeType.original.rawValue + suffix,
                                             with: SchemeType.custom.rawValue + suffix)
    }
    
}
