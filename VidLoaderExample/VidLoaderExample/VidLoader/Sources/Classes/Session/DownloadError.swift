//
//  DownloadError.swift
//  VidLoader
//
//  Created by Petre on 14.11.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import Foundation

public enum DownloadError: Swift.Error, Equatable, Codable {
    case unknown
    case taskNotCreated
    case custom(VidLoaderError)

    init(error: Error?) {
        let error = error ?|> VidLoaderError.init ?|> DownloadError.custom
        self = error ?? .unknown
    }

    public static func == (lhs: DownloadError, rhs: DownloadError) -> Bool {
        switch (lhs, rhs) {
        case (.unknown, .unknown), (.taskNotCreated, .taskNotCreated), (.custom, .custom): return true
        default: return false
        }
    }

    private enum CodingKeys: String, CodingKey {
      case base, vidLoaderError
    }

    private enum Base: String, Codable {
      case unknown, taskNotCreated, custom
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let base = try container.decode(Base.self, forKey: .base)
        switch base {
        case .unknown:
          self = .unknown
        case .taskNotCreated:
            self = .taskNotCreated
        case .custom:
          let error = try container.decode(VidLoaderError.self, forKey: .vidLoaderError)
          self = .custom(error)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .unknown:
            try container.encode(Base.unknown, forKey: .base)
        case .taskNotCreated:
            try container.encode(Base.taskNotCreated, forKey: .base)
        case .custom(let error):
            try container.encode(Base.custom, forKey: .base)
            try container.encode(error, forKey: .vidLoaderError)
        }
    }
}
