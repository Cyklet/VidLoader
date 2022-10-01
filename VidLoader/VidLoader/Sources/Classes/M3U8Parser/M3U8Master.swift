//
//  M3U8Master.swift
//  VidLoader
//
//  Created by Petre on 01.09.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import AVFoundation

protocol MasterParser {
    func adjust(data: Data, completion: @escaping (Result<Data, M3U8Error>) -> Void)
}

final class M3U8Master: MasterParser {
    private let executionQueue: VidLoaderExecutionQueueable
    private let time: () -> DispatchTime
    
    init(executionQueue: VidLoaderExecutionQueueable = VidLoaderExecutionQueue(label: "com.vidloader.master_parser_queue"),
         time: @escaping () -> DispatchTime = { DispatchTime.now() } ) {
        self.time = time
        self.executionQueue = executionQueue
    }

    func adjust(data: Data, completion: @escaping (Result<Data, M3U8Error>) -> Void) {
        // For m3u8 master file shouldWaitForLoadingOfRequestedResource in iOS 16 behaves differently,
        // adjustMasterFile is a sync operation without having any request in place.
        // Session is failling with CoreMediaErrorDomain Code=-12640, to avoid this issue we add an artificial delay for adjustMasterFile (as a temporary solution)
        // in case session still needs more time to handle AVAssetResourceLoadingRequest finishLoading operation it still may fail
        executionQueue.asyncAfter(deadline: time() + 0.5) { [weak self] in
            guard let self = self else { return }
            completion(self.check(data: data))
        }
    }
    
    // MARK: - Private functions
    
    private func check(data: Data) -> Result<Data, M3U8Error> {
        guard let response = data.string else {
            return .failure(.dataConversion)
        }
        guard let data = replacePaths(response: response).data else {
            return .failure(.dataConversion)
        }
        
        return .success(data)
    }
    
    private func replacePaths(response: String) -> String {
        let suffix = "://"
        return response.replacingOccurrences(of: SchemeType.original.rawValue + suffix,
                                             with: SchemeType.custom.rawValue + suffix)
    }
}
