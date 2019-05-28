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
    
    func testStationWrapperParsing() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let jsonData = wrapperJson.data(using: .utf8)!
        let mockStationWrapper = try networking.decodeStationData(data: jsonData, decoderClass: NYCStationInfoWrapper.self)
        let directly = NYCStationInfoWrapper(last_updated: Date(timeIntervalSinceReferenceDate: 1559060968), data: ["stations":[]])
        
        XCTAssertEqual(mockStationWrapper.last_updated, directly.last_updated)
        XCTAssertEqual(mockStationWrapper.data.count , directly.data.count)
    }

    func testStationsParsing() throws{
        
        let jsonData = stationJson.data(using: .utf8)!
        let data = try networking.decodeStationData(data: jsonData, decoderClass: [NYCBikeStationInfo].self)
        
        XCTAssert(data.count == 2)
        
    }
    
}
