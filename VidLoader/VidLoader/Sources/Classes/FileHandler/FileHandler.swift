//
//  FileHandler.swift
//  VidLoader
//
//  Created by Petre on 14.11.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import Foundation

protocol FileHandleable {
    func deleteContent(for item: ItemInformation)
}

class FileHandler: FileHandleable {
    private let fileManager: FileManageable
    private let executionQueue: VidLoaderExecutionQueueable

    init(fileManager: FileManageable = FileManager.default,
         executionQueue: VidLoaderExecutionQueueable = VidLoaderExecutionQueue(label: "com.vidloader.file_manager_queue")) {
        self.fileManager = fileManager
        self.executionQueue = executionQueue
    }

    // MARK: - FileHandleable

    func deleteContent(for item: ItemInformation) {
        guard let location = item.location, item.isReachable else { return }
        executionQueue.async { [weak self] in
            try? self?.fileManager.removeItem(atPath: location.path)
        }
    }
}
