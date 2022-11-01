//
//  PlaylistLoader.swift
//  VidLoader
//
//  Created by Petre on 01.09.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import Foundation

protocol PlaylistLoadable {
    var nextStreamResource: (String, StreamResource)? { get }
    func load(identifier: String, at url: URL, headers: [String: String]?,
              completion: @escaping Completion<Result<Void, Error>>)
    func cancel(identifier: String)
}

final class PlaylistLoader: PlaylistLoadable {
    private let requestsInProgress = Atomic<[String: URLSessionDataTask]>([:])
    private var streamsResources = Atomic<[(identifier: String, StreamResource)]>([])
    private let requestable: Requestable

    init(requestable: Requestable = URLSession.shared) {
        self.requestable = requestable
    }

    // MARK: - PlaylistLoadable

    var nextStreamResource: (String, StreamResource)? {
        guard !streamsResources.value.isEmpty else {
            return nil
        }
        return streamsResources.value.removeFirst()
    }

    func load(identifier: String, at url: URL, headers: [String: String]?, completion: @escaping Completion<Result<Void, Error>>) {
        let handle: (HTTPURLResponse, Data) -> Void = { [weak self] response, data in
            let streamResource = StreamResource(response: response, data: data)
            self?.addStreamResource(streamResource, identifier: identifier)
            completion(.success(()))
        }
        
        var urlRequest = URLRequest(url: url)
        headers?.forEach {
            urlRequest.addValue($0.value, forHTTPHeaderField: $0.key)
        }
        let dataTask = requestable.dataTask(with: urlRequest) { [weak self] data, response, error in
            self?.removeFromRelay(identifier)
            guard let response = response as? HTTPURLResponse, let data = data else {
                return completion(.failure(error ?? DownloadError.unknown))
            }
            handle(response, data)
        }
        dataTask.resume()

        addToRelay(identifier: identifier, dataTask: dataTask)
    }

    func cancel(identifier: String) {
        requestsInProgress.value[identifier]?.cancel()
        removeStreamResource(identifier: identifier)
        removeFromRelay(identifier)
    }

    // MARK: - Private

    private func addToRelay(identifier: String, dataTask: URLSessionDataTask) {
        var requests = requestsInProgress.value
        requests.removeValue(forKey: identifier)?.cancel()
        requests[identifier] = dataTask
        requestsInProgress.value = requests
    }

    private func removeFromRelay(_ identifier: String) {
        requestsInProgress.value[identifier] = nil
    }

    private func addStreamResource(_ streamResource: StreamResource, identifier: String) {
        streamsResources.value = streamsResources.value + [(identifier, streamResource)]
    }

    private func removeStreamResource(identifier: String) {
        streamsResources.value = streamsResources.value.filter { $0.identifier != identifier }
    }
}
