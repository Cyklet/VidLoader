//
//  NetworkHandlerTests.swift
//  VidLoaderTests
//
//  Created by Petre on 12/6/19.
//  Copyright © 2019 Petre. All rights reserved.
//
import XCTest
@testable import VidLoader

final class NetworkHandlerTests: XCTestCase {
    private var networkHandler: Network!
    private var reachable: MockReachable!
    
    override func setUp() {
        super.setUp()
        
        reachable = MockReachable()
        networkHandler = NetworkHandler(reachable: reachable)
    }
    
    func test_NotificationObserver_ConnectionWasChanged_ClosureWillBeCalled() {
        // GIVEN
        let expectedNetworkState: NetworkState = .available
        var resultNetworkState: NetworkState?
        reachable.connection = .unavailable
        networkHandler.setup(networkChanged: { state in
            resultNetworkState = state
        })
        
        // WHEN
        reachable.connection = .wifi
        NotificationCenter.default.post(name: .reachabilityChanged, object: nil)
        
        // THEN
        XCTAssertEqual(expectedNetworkState, resultNetworkState)
    }
    
    func test_SetNewMobileDataAccess_ValueIsSame_ClosureWillNotBeCalled() {
        // GIVEN
        var resultNetworkState: NetworkState?
        reachable.connection = .wifi
        networkHandler.enableMobileDataAccess()
        networkHandler.setup(networkChanged: { state in
            resultNetworkState = state
        })
        
        // WHEN
        reachable.connection = .cellular
        networkHandler.enableMobileDataAccess()
        
        // THEN
        XCTAssertNil(resultNetworkState)
    }
    
    func test_EnableMobileDataAccess_NoChanges_ClosureWillNotBeCalled() {
        // GIVEN
        var resultNetworkState: NetworkState?
        networkHandler.disableMobileDataAccess()
        networkHandler.setup(networkChanged: { state in
            resultNetworkState = state
        })
        
        // WHEN
        networkHandler.enableMobileDataAccess()
        
        // THEN
        XCTAssertNil(resultNetworkState)
    }
    
    func test_EnableMobileDataAccess_ConnectionChanged_ClosureWillBeCalled() {
        // GIVEN
        let expectedNetworkState: NetworkState = .available
        var resultNetworkState: NetworkState?
        networkHandler.disableMobileDataAccess()
        networkHandler.setup(networkChanged: { state in
            resultNetworkState = state
        })
        
        // WHEN
        reachable.connection = .cellular
        networkHandler.enableMobileDataAccess()
        
        // THEN
        XCTAssertEqual(expectedNetworkState, resultNetworkState)
    }
    
    func test_DisableDataAccess_OnlyCellularIsAvailable_NetworkStateIsUnavailable() {
        // GIVEN
        let expectedNetworkState: NetworkState = .unavailable
        var resultNetworkState: NetworkState?
        reachable.connection = .cellular
        networkHandler.setup(networkChanged: { state in
            resultNetworkState = state
        })
        
        // WHEN
        networkHandler.disableMobileDataAccess()
        
        // THEN
        XCTAssertEqual(expectedNetworkState, resultNetworkState)
    }
    
    func test_DisableDataAccess_WifiIsAvailable_NetworkStateIsAvailable() {
        // GIVEN
        let expectedNetworkState: NetworkState = .available
        var resultNetworkState: NetworkState?
        reachable.connection = .wifi
        networkHandler.setup(networkChanged: { state in
            resultNetworkState = state
        })
        
        // WHEN
        networkHandler.disableMobileDataAccess()
        
        // THEN
        XCTAssertEqual(expectedNetworkState, resultNetworkState)
    }
    
}
