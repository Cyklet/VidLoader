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
    
    func testNotificationObserverWhenConnectionWasChangedClosureWillBeCalled() {
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
    
    func testSetNewMobileDataAccessWheValueIsSameThenClosureWillNotBeCalled() {
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
    
    func testEnableMobileDataAccessWheNoChangesThenClosureWillNotBeCalled() {
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
    
    func testEnableMobileDataAccessWhenConnectionChangedThenClosureWillBeCalled() {
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
    
    func testDisableDataAccessWhenOnlyCellularIsAvailableThenNetworkStateIsUnavailable() {
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
    
    func testDisableDataAccessWhenWifiIsAvailableThenNetworkStateIsAvailable() {
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
