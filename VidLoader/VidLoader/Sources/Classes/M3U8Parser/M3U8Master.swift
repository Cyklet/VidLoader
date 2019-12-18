//
//  M3U8Master.swift
//  VidLoader
//
//  Created by Petre on 01.09.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import AVFoundation

protocol MasterParser {
    func adjust(data: Data) -> Result<Data, M3U8Error>
}

struct M3U8Master: MasterParser {
    func adjust(data: Data) -> Result<Data, M3U8Error> {
        guard let response = data.string else {
            return .failure(.dataConversion)
        }
        guard let data = replacePaths(response: response).data else {
            return .failure(.dataConversion)
        }
        
        return .success(data)
    }
    
    // MARK: - Private functions
    
    func replacePaths(response: String) -> String {
        let suffix = "://"
        
        return response.replacingOccurrences(of: SchemeType.original.rawValue + suffix,
                                             with: SchemeType.custom.rawValue + suffix)
    }
}
