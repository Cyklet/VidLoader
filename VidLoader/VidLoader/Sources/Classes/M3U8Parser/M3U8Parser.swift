//
//  M3U8Parser.swift
//  VidLoader
//
//  Created by Petre on 01.09.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import AVFoundation

protocol Parser {
    func adjust(data: Data, completion: @escaping (Result<Data, M3U8Error>) -> Void)
}

protocol StreamContentRepresentable {
    func adjust(response: String, completion: @escaping (Result<String, M3U8Error>) -> Void)
}

struct M3U8Parser: Parser {
    private let streamInf = "#EXT-X-STREAM-INF"
    private let requestable: Requestable
    
    init(requestable: Requestable = URLSession.shared) {
        self.requestable = requestable
    }
    
    // MARK: - Parser
    
    func adjust(data: Data,
                completion: @escaping (Result<Data, M3U8Error>) -> Void) {
        let response = data.string
        content(response: response).adjust(response: response) { result in
            switch result {
            case .success(let value):
                guard let data = value.data else {
                    return completion(.failure(.dataConversion))
                }
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private functions
    
    private func content(response: String) -> StreamContentRepresentable {
        let items = response.components(separatedBy: streamInf)

        return items.count > 1 ? M3U8Master() : M3U8Playlist(requestable: requestable)
    }
}
