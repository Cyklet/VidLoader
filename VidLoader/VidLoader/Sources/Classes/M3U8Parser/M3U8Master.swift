//
//  M3U8Master.swift
//  VidLoader
//
//  Created by Petre on 01.09.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import AVFoundation

protocol MasterParser {
    func adjust(data: Data, baseURL: URL) -> Result<Data, M3U8Error>
}

final class M3U8Master: MasterParser {
    func adjust(data: Data, baseURL: URL) -> Result<Data, M3U8Error> {
        guard let response = data.string else {
            return .failure(.dataConversion)
        }
        let newResponse = replaceRelativePaths(response: response, with: baseURL) |> replaceOriginalSchemes(response:)
        guard let data = newResponse.data else {
            return .failure(.dataConversion)
        }
        
        return .success(data)
    }
    
    // MARK: - Private functions
    
    /// Replace all original https schemes with variant scheme
    /// - Parameter response: m3u8 file string format
    /// - Returns: Updated response with replaced schemes
    private func replaceOriginalSchemes(response: String) -> String {
        let suffix = "://"
        return response.replacingOccurrences(of: SchemeType.original.rawValue + suffix,
                                             with: SchemeType.variant.rawValue + suffix)
    }
    
    /// Transform all relative URLs in absolute URLs, if playlists has already a scheme then URL will remain untouched
    /// - Parameters:
    ///   - response: m3u8 file in string format
    ///   - baseURL: Master/variant stream resource URL
    /// - Returns: Updated response with absolute URLs
    private func replaceRelativePaths(response: String, with baseURL: URL) -> String {
        guard let newBaseURL = baseURL.withScheme(scheme: .variant)?.deletingLastPathComponent() else {
            return response
        }
        let relativePlaylists = response.matches(for: RegexStrings.relativePlaylist)
        let uris =  response.matches(for: RegexStrings.uri).filter { URL(string: $0)?.scheme == nil }

        return (relativePlaylists + uris)
            .reduce(into: response) { result, path in
                let absoluteURLString = newBaseURL.appendingPathComponent(path).absoluteString
                result = result.replacingOccurrences(of: path, with: absoluteURLString)
            }
    }
}
