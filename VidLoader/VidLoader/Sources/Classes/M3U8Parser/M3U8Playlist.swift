//
//  M3U8Playlist.swift
//  VidLoader
//
//  Created by Petre on 01.09.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import AVFoundation

let variantChunkKey = "#EXTINF"

protocol PlaylistParser {
    func adjust(data: Data, with baseURL: URL, completion: @escaping (Result<Data, M3U8Error>) -> Void)
}

final class M3U8Playlist: PlaylistParser {
    private let requestable: Requestable
    private let keyRegex: String = {
        let encryptionKey = "#EXT-X-KEY"
        let uriKey = "URI=\""

        return "\(encryptionKey)[\\S\\s\\n]*?\(uriKey)([^\\n,\"]+)"
    }()
    private let relativeChunksRegex: String = {
        return "\(variantChunkKey).*?[,\\n]((?!\(SchemeType.original.rawValue)).[\\S\\s]+?(?=\\n|#))"
    }()

    init(requestable: Requestable = URLSession.shared) {
        self.requestable = requestable
    }

    // MARK: - StreamContentRepresentable
    
    func adjust(data: Data, with baseURL: URL, completion: @escaping (Result<Data, M3U8Error>) -> Void) {
        guard let response = data.string else {
            return completion(.failure(.dataConversion))
        }
        let newResponse = replaceRelativeChunks(response: response, with: baseURL)
        replacePaths(response: newResponse, with: baseURL, completion: { result in
            switch result {
            case .success: completion(result)
            case .failure(let error):
                switch error {
                case .custom, .dataConversion, .keyContentWrong: completion(result)
                case .keyURLMissing: completion(.success(newResponse.data!))
                }
            }
        })
    }

    // MARK - Private functions
    
    private func replacePaths(response: String,
                              with baseURL: URL,
                              completion: @escaping (Result<Data, M3U8Error>) -> Void) {
        let keysURLs = response.matches(for: keyRegex).compactMap { generateURL(keyPath: $0, baseURL: baseURL) }
        guard !keysURLs.isEmpty else {
            return completion(.failure(.keyURLMissing))
        }
        download(keysURLs: keysURLs) { result in
            let newResponse = result.reduce(response, { result, values in
                result.replacingOccurrences(of: values.0, with: values.1)
            })
            guard let data = newResponse.data else {
                return completion(.failure(.dataConversion))
            }
            completion(.success(data))
        }
    }
    
    
    /// Recursive download all encryption keys inside of variant response
    /// - Parameters:
    ///   - keysURLs: Keys URL that need to be downlaoded
    ///   - values: Recursive storage for response
    ///   - completion: Return array of tuple here first element is url from where the key was downloaded and second is modified key with a scheme
    private func download(keysURLs: [URL], values: [(String, String)] = [], completion: @escaping ([(String, String)]) -> Void) {
        guard let url = keysURLs.first else {
            return completion(values)
        }
        downloadKey(from: url, completion: { [weak self] result in
            switch result {
            case let .success(value):
                self?.download(keysURLs: Array(keysURLs.dropFirst()), values: values + [(url.absoluteString, value)], completion: completion)
            case .failure:
                self?.download(keysURLs: Array(keysURLs.dropFirst()), values: values, completion: completion)
            }
        })
    }
    
    private func downloadKey(from url: URL, completion: @escaping (Result<String, M3U8Error>) -> Void) {
        let task = requestable.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data else {
                return completion(.failure(.custom(error ?|> VidLoaderError.init)))
            }
            guard let key = URL(string: data.base64EncodedString())?.withScheme(scheme: .key)?.absoluteString else {
                return completion(.failure(.keyContentWrong))
            }
            completion(.success(key))
        }
        task.resume()
    }
    
    private func generateURL(keyPath: String, baseURL: URL) -> URL? {
        if let keyURL = URL(string: keyPath), keyURL.scheme != nil {
            return keyURL
        }
        let originalBaseURL = baseURL.withScheme(scheme: .original)?.deletingLastPathComponent()

        return originalBaseURL?.appendingPathComponent(keyPath)
    }
    
    
    /// Transform all relative URLs in absolute URLs, if chunk has already a scheme then link will remain untouched
    /// - Parameters:
    ///   - response: Variant response string
    ///   - baseURL: Master/variant URL
    /// - Returns: Update response with absolute URLs inside of it
    private func replaceRelativeChunks(response: String, with baseURL: URL) -> String {
        guard let originalBaseURL = baseURL.withScheme(scheme: .original)?.deletingLastPathComponent() else {
            return response
        }
        let paths = response.matches(for: relativeChunksRegex)
        return paths.reduce(into: response) { result, path in
            let absoluteURLString = originalBaseURL.appendingPathComponent(path).absoluteString
            result = result.replacingOccurrences(of: path, with: absoluteURLString)
        }
    }
}
