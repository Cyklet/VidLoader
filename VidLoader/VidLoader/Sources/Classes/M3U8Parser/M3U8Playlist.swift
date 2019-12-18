//
//  M3U8Playlist.swift
//  VidLoader
//
//  Created by Petre on 01.09.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import AVFoundation

protocol PlaylistParser {
    func adjust(data: Data, with baseURL: URL, completion: @escaping (Result<Data, M3U8Error>) -> Void)
}

struct M3U8Playlist: PlaylistParser {
    private let requestable: Requestable
    private let keyRegex: String = {
        let encryptionKey = "#EXT-X-KEY"
        let uriKey = "URI=\""

        return "\(encryptionKey)[\\S\\s\\n]*?\(uriKey)([^\\n,\"]+)"
    }()
    private let relativeChunksRegex: String = {
        let chunkKey = "#EXTINF"

        return "\(chunkKey).*?,[\\n]?((?!\(SchemeType.original.rawValue)).[\\S\\s]+?(?=\\n|#))"
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
        replacePaths(response: newResponse, with: baseURL, completion: completion)
    }

    // MARK - Private functions
    
    private func replacePaths(response: String,
                              with baseURL: URL,
                              completion: @escaping (Result<Data, M3U8Error>) -> Void) {
        guard let keyPath = response.matches(for: keyRegex).first,
            let keyURL = generateURL(keyPath: keyPath, baseURL: baseURL) else {
                return completion(.failure(.keyURLMissing))
        }
        downloadKey(url: keyURL, completion: { result in
            switch result {
            case .success(let key):
                guard let keyContentURL = URL(string: key)?.withScheme(scheme: .key) else {
                    return completion(.failure(.keyContentWrong))
                }
                let newResponse = response.replacingOccurrences(of: keyPath, with: keyContentURL.absoluteString)
                guard let data = newResponse.data else {
                    return completion(.failure(.dataConversion))
                }
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    private func generateURL(keyPath: String, baseURL: URL) -> URL? {
        if let keyURL = URL(string: keyPath), keyURL.scheme != nil {
            return keyURL
        }
        let originalBaseURL = baseURL.withScheme(scheme: .original)?.deletingLastPathComponent()

        return originalBaseURL?.appendingPathComponent(keyPath)
    }
    
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
    
    private func downloadKey(url: URL, completion: @escaping (Result<String, M3U8Error>) -> Void) {
        let task = requestable.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data else {
                return completion(.failure(.custom(error ?|> VidLoaderError.init)))
            }
            completion(.success(data.base64EncodedString()))
        }
        task.resume()
    }
}
