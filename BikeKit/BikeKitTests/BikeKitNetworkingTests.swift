//
//  BikeKitTests.swift
//  BikeKitTests
//
//  Created by Joss Manger on 5/8/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import XCTest
@testable import BikeKit

class BikeKitNetworkingTests: XCTestCase {

    var networking:NYCBikeNetworking!
    var model:NYCBikeModel!
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        model = NYCBikeModel()
        networking = model.networking
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        networking = nil
        model = nil
    }

    func testRequestSetup() throws {
        
        let request = networking.createRequest(url: NYCBikeConstants.URLS.STATION_INFO_URL)
        
        XCTAssertEqual(request.url?.scheme,"https")
        XCTAssertEqual(request.url?.host,"gbfs.citibikenyc.com")
        XCTAssertEqual(request.url?.query,nil)
        
    }
    
    
    func testRefreshThrottleFails(){
        
        networking.refreshThrottle = Date()
        
        let response = networking.checkTimeoutHasExpired(now: Date())
        
        XCTAssertFalse(response)
        
        
    }
 
    func testRefreshThrottleSucceeds(){
        
        networking.refreshThrottle = Date().addingTimeInterval(19)
        
        let response = networking.checkTimeoutHasExpired(now: Date())
        
        XCTAssertFalse(response)
        
        networking.refreshThrottle = Date().addingTimeInterval(20)
        
        let secondTest = networking.checkTimeoutHasExpired(now: Date())
        
        XCTAssertFalse(secondTest)
        
    }
    
}
