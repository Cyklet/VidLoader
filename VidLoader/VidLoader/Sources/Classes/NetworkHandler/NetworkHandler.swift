//
//  NetworkHandler.swift
//  VidLoader
//
//  Created by Petre on 14.11.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import Foundation

protocol Network {
    func setup(networkChanged: @escaping (NetworkState) -> Void)
    func enableMobileDataAccess()
    func disableMobileDataAccess()
}

final class NetworkHandler: NSObject, Network {
    private let reachable: Reachable?
    private var networkChanged: ((NetworkState) -> Void)?
    private var state: NetworkState? {
        didSet {
            if oldValue == state { return }
            state.map { networkChanged?($0) }
        }
    }
    private var isMobileDataAccessEnabled: Bool? {
        didSet {
            if oldValue == isMobileDataAccessEnabled { return }
            state = newState
        }
    }

    init(reachable: Reachable? = try? Reachability()) {
        self.reachable = reachable
        try? reachable?.startNotifier()

        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(self.networkStateChanged),
                                               name: .reachabilityChanged, object: nil)
    }

    // MARK: - Network

    func setup(networkChanged: @escaping (NetworkState) -> Void) {
        self.networkChanged = networkChanged
    }

    func enableMobileDataAccess() {
        isMobileDataAccessEnabled = true
    }

    func disableMobileDataAccess() {
        isMobileDataAccessEnabled = false
    }

    // MARK: - Private functions

    @objc private func networkStateChanged(notification: Notification) {
        state = newState
    }

    private var newState: NetworkState {
        switch (reachable?.connection, isMobileDataAccessEnabled) {
        case (.unavailable, _), (nil, _), (.none?, _), (.cellular, false): return .unavailable
        default: return .available
        }
    }
}
