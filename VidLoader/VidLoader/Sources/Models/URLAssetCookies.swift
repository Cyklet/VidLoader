//
//  URLAssetCookies.swift
//  VidLoader
//
//  Created by Marcos Joshoa on 29/03/23.
//

import Foundation

struct URLAssetCookies : Codable, Equatable {
    let values: [HTTPCookie]
    
    public enum Error: Swift.Error {
        case unarchiveFailed
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let data = try container.decode(Data.self)
        guard let values = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [HTTPCookie] else {
            throw Error.unarchiveFailed
        }
        self.values = values
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let data = try NSKeyedArchiver.archivedData(withRootObject: values, requiringSecureCoding: false)
        try container.encode(data)
    }
}
