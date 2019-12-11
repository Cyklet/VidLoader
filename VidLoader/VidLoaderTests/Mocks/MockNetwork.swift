//
//  MockNetwork.swift
//  VidLoaderTests
//
//  Created by Petre on 12/11/19.
//  Copyright © 2019 Petre. All rights reserved.
//

@testable import VidLoader

final class MockNetwork: Network {
    var setupFuncCheck = EmptyFuncCheck()
    var setupStub: ((NetworkState) -> Void)?
    func setup(networkChanged: @escaping (NetworkState) -> Void) {
        setupStub = networkChanged
        setupFuncCheck.call()
    }
    var enableMobileDataAccessFuncCheck = EmptyFuncCheck()
    func enableMobileDataAccess() {
        enableMobileDataAccessFuncCheck.call()
    }
    
    var disableMobileDataAccessFuncCheck = EmptyFuncCheck()
    func disableMobileDataAccess() {
        disableMobileDataAccessFuncCheck.call()
    }
}
