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
    let showRunningActions: () -> Void
    let showPausedActions: () -> Void
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
    
    private struct Colors {
        static let limeGreen: UIColor = .init(red: 50 / 255.0, green: 205 / 255.0 , blue: 50 / 255.0, alpha: 1)
        static let fireBrick: UIColor = .init(red: 178 / 255.0, green: 34 / 255.0 , blue: 34 / 255.0, alpha: 1)
        static let gold: UIColor = .init(red: 255 / 255.0, green: 215 / 255.0 , blue: 0 / 255.0, alpha: 1)
    }

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
        case .keyLoaded:
            setupButton(title: "Asset loaded")
        case .canceled, .unknown:
            setupButton(title: "Download")
        case .completed:
            setupButton(title: "Downloaded")
        case .failed:
            setupButton(title: "Failed", color: Colors.fireBrick)
        case .prefetching:
            setupButton(title: "Prefetchin")
        case .running(let progress), .noConnection(let progress):
            setupButton(title: "\(String(format: "%.0f", progress * 100)) %")
        case .paused(let progress):
            setupButton(title: "\(String(format: "%.0f", progress * 100)) %", color: Colors.gold)
        case .waiting:
            setupButton(title: "Waiting")
        }
    }

    private func setupButton(title: String, color: UIColor = Colors.limeGreen) {
        DispatchQueue.main.async {
            self.stateButton.setTitle(title, for: .normal)
            self.stateButton.setTitleColor(color, for: .normal)
        }
    }

    // MARK: - Actions

    @IBAction private func performAction() {
        switch state {
        case .completed:
            actions?.deleteVideo()
        case .keyLoaded, .prefetching:
            return
        case .failed:
            actions?.resumeFailedVideo()
        case .canceled, .unknown:
            actions?.startDownload()
        case .waiting:
            actions?.cancelDownload()
        case .running, .noConnection:
            actions?.showRunningActions()
        case .paused:
            actions?.showPausedActions()
        }
    }
}
