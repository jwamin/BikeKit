//
//  NYCBikeConstaints.swift
//  BikeKit
//
//  Created by Joss Manger on 5/15/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import Foundation

public struct NYCBikeConstants {

    public static let TIMEOUT_THROTTLE:TimeInterval = 20

    public static let calculateNearestMax:Int = 4

    public static let favouritesUserDefaultsKey = "favourites"
    
    /// CitiBike GBFS endpoint URLS
    //TODO: Refactor to use only the primary endpoint URL
    public struct URLS {
        
        public static let ALL_DATA_URL = URL(string:"https://gbfs.citibikenyc.com/gbfs/gbfs.json")!
        public static let STATION_INFO_URL = URL(string:"https://gbfs.citibikenyc.com/gbfs/en/station_information.json")!
        public static let STATION_STATUS_URL = URL(string:"https://gbfs.citibikenyc.com/gbfs/en/station_status.json")!
    }

}
