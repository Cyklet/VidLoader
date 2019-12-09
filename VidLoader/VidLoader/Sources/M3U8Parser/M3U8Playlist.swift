//
//  M3U8Playlist.swift
//  VidLoader
//
//  Created by Petre on 01.09.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import AVFoundation

struct M3U8Playlist: StreamContentRepresentable {
    private let schemeHandler: SchemeHandler
    private let requestable: Requestable
    private let keyRegex: String = {
        let encryptionKeyPrefix = "URI=\""
        
        return "(?<=\(encryptionKeyPrefix))[^\n,\"]+"
    }()

    init(schemeHandler: SchemeHandler = .init(),
         requestable: Requestable = URLSession.shared) {
        self.schemeHandler = schemeHandler
        self.requestable = requestable
    }

    // MARK: - StreamContentRepresentable

    func adjust(response: String, completion: @escaping (Result<String, M3U8Error>) -> Void) {
        guard let keyStringURL = response.matches(for: keyRegex).first,
            let keyURL = URL.init(string: keyStringURL) else {
                return completion(.failure(.keyURLMissing))
        }
        downloadKey(url: keyURL, completion: { result in
            switch result {
            case .success(let key):
                guard let keyContentURL = URL(string: key)?.withScheme(scheme: .key) else {
                    return completion(.failure(.keyContentWrong))
                }
                let value = response.replacingOccurrences(of: keyURL.absoluteString, with: keyContentURL.absoluteString)
                completion(.success(value))
            case .failure:
                completion(result)
            }
        })
    }

    // MARK - Private functions
    
    private func downloadKey(url: URL, completion: @escaping (Result<String, M3U8Error>) -> Void) {
        let task = requestable.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data else {
                return completion(.failure(.server(error)))
            }
            completion(.success(data.base64EncodedString()))
        }
        task.resume()
    }
}
