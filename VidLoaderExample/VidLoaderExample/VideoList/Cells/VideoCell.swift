//
//  VideoCell.swift
//  VidLoaderExample
//
//  Created by Petre on 18.10.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import UIKit
import VidLoader

struct VideoCellActions {
    let deleteVideo: () -> Void
    let cancelDownload: () -> Void
    let startDownload: () -> Void
    let resumeFailedVideo: () -> Void
}

struct VideoCellModel {
    let identifier: String
    let title: String
    let thumbnailName: String
    let state: DownloadState
    let actions: VideoCellActions
}

final class VideoCell: UITableViewCell {
    static let identifier = String(describing: VideoCell.self)
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var thumbnailImageView: UIImageView!
    @IBOutlet private var stateButton: UIButton!
    private var actions: VideoCellActions?
    private var state: DownloadState = .unknown
    private var observer: VidObserver?

    override func prepareForReuse() {
        super.prepareForReuse()

        VidLoaderHandler.shared.loader.remove(observer: observer)
        observer = nil
    }

    func setup(model: VideoCellModel) {
        self.actions = model.actions
        setup(state: model.state)
        titleLabel.text = model.title
        thumbnailImageView.image = UIImage(named: model.thumbnailName)
        observer = VidObserver(type: .single(model.identifier),
                               stateChanged: { [weak self] item in self?.setup(state: item.state) })
        VidLoaderHandler.shared.loader.observe(with: observer)
    }

    // MARK: - Private functions

    private func setup(state: DownloadState) {
        self.state = state
        print("#### VideoCell: \(state)")
        switch state {
        case .assetInfoLoaded:
            setupButton(title: "Asset loaded")
        case .canceled, .unknown:
            setupButton(title: "Download")
        case .completed:
            setupButton(title: "Downloaded")
        case .failed:
            setupButton(title: "Failed")
        case .prefetching:
            setupButton(title: "Prefetchin")
        case .running(let progress), .suspended(let progress):
            setupButton(title: "\(String(format: "%.0f", progress * 100)) %")
        case .waiting:
            setupButton(title: "Waiting")
        }
    }

    private func setupButton(title: String) {
        DispatchQueue.main.async { self.stateButton.setTitle(title, for: .normal) }
    }

    // MARK: - Actions

    @IBAction private func performAction() {
        switch state {
        case .completed:
            actions?.deleteVideo()
        case .assetInfoLoaded, .prefetching:
            return
        case .failed:
            actions?.resumeFailedVideo()
        case .canceled, .unknown:
            actions?.startDownload()
        case .waiting, .running, .suspended:
            actions?.cancelDownload()
        }
    }
}
