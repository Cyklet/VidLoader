//
//  VideoListController.swift
//  VidLoaderExample
//
//  Created by Petre on 14.10.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import UIKit
import AVKit

class VideoListController: UIViewController, UITableViewDelegate, UITableViewDataSource, StoryboardLoadable {
    @IBOutlet private var table: UITableView!
    var dataProvider: VideoListDataProviding!

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataProvider.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VideoCell.identifier, for: indexPath)
        (cell as? VideoCell)?.setup(model: dataProvider.videoModel(row: indexPath.row))

        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let urlAsset = dataProvider.urlAsset(row: indexPath.row) else { return }
        startVideo(urlAsset: urlAsset)
    }

    // MARK: - Private functions

    private func startVideo(urlAsset: AVURLAsset) {
        let item = AVPlayerItem(asset: urlAsset)
        let player = AVPlayer(playerItem: item)
        let controller = AVPlayerViewController()
        controller.player = player
        navigationController?.pushViewController(controller, animated: true)
        player.play()
    }

    private func setup() {
        table.delegate = self
        table.dataSource = self
        table.register(UINib(nibName: VideoCell.identifier, bundle: nil),
                       forCellReuseIdentifier: VideoCell.identifier)
        dataProvider.setupActions(
            showRemoveActionSheet: { [weak self] data in self?.showRemoveActionsSheet(with: data) },
            showStopActionSheet: { [weak self] data in self?.showStopActionsSheet(with: data) },
            showFailedActionSheet: { [weak self] data in self?.showFailedActionSheet(with: data) },
            reloadData: { [weak self] in self?.table.reloadData() }
        )
    }

    private func showRemoveActionsSheet(with data: VideoData) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.dataProvider.deleteVideo(with: data)
            self?.table.reloadData()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(actionSheet, animated: true)
    }

    private func showStopActionsSheet(with data: VideoData) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Stop", style: .destructive, handler: { [weak self] _ in
            self?.dataProvider.stopDownload(with: data)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(actionSheet, animated: true)
    }
    
    private func showFailedActionSheet(with data: VideoData) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.dataProvider.deleteVideo(with: data)
            self?.table.reloadData()
        }))
        actionSheet.addAction(UIAlertAction(title: "Retry", style: .default, handler: { [weak self] _ in
            self?.dataProvider.startDownload(with: data)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(actionSheet, animated: true)
    }
}

