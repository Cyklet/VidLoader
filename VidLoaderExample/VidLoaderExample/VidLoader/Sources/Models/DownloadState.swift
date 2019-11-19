//
//  DownloadState.swift
//  VidLoader
//
//  Created by Petre on 01.09.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import Foundation

public enum DownloadState: Equatable, Codable {
    case prefetching
    case running(Double)
    case suspended(Double)
    case completed
    case canceled
    case unknown
    case waiting
    case failed(error: DownloadError)
    case assetInfoLoaded

    init(taskState: URLSessionTask.State, progress: Double) {
        self = DownloadState.new(from: taskState, progress: progress)
    }

    // MARK: - Private

    private static func new(from taskState: URLSessionTask.State, progress: Double) -> DownloadState {
        switch taskState {
        case .completed: return .completed
        case .running: return .running(progress)
        case .suspended: return .suspended(progress)
        case .canceling: return .unknown
        @unknown default: return .unknown
        }
    }


    private enum CodingKeys: String, CodingKey {
      case base, downloadError, progress
    }

    private enum Base: String, Codable {
      case prefetching, running, suspended, completed, canceled, unknown, waiting, failed, assetInfoLoaded
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let base = try container.decode(Base.self, forKey: .base)
        switch base {
        case .prefetching:
            self = .prefetching
        case .running:
            let progress = try container.decode(Double.self, forKey: .progress)
            self = .running(progress)
        case .suspended:
            let progress = try container.decode(Double.self, forKey: .progress)
            self = .suspended(progress)
        case .completed:
            self = .completed
        case .canceled:
            self = .canceled
        case .unknown:
            self = .unknown
        case .waiting:
            self = .waiting
        case .failed:
            let error = try container.decode(DownloadError.self, forKey: .downloadError)
            self = .failed(error: error)
        case .assetInfoLoaded:
            self = .assetInfoLoaded
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .prefetching:
            try container.encode(Base.prefetching, forKey: .base)
        case .running(let progress):
            try container.encode(Base.running, forKey: .base)
            try container.encode(progress, forKey: .progress)
        case .suspended(let progress):
            try container.encode(Base.suspended, forKey: .base)
            try container.encode(progress, forKey: .progress)
        case .completed:
            try container.encode(Base.completed, forKey: .base)
        case .canceled:
            try container.encode(Base.canceled, forKey: .base)
        case .unknown:
            try container.encode(Base.unknown, forKey: .base)
        case .waiting:
            try container.encode(Base.waiting, forKey: .base)
        case .failed(let error):
            try container.encode(Base.failed, forKey: .base)
            try container.encode(error, forKey: .downloadError)
        case .assetInfoLoaded:
            try container.encode(Base.assetInfoLoaded, forKey: .base)
        }
    }
}
