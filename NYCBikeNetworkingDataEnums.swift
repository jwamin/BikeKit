//
//  NYCBikeNetworkingDataEnums.swift
//  BikeKit
//
//  Created by Joss Manger on 5/21/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import Foundation

public enum BikeNetworkingError : Error{
    case throttled
    case newData
    case failed
}

public enum NYCBikeRequestType{
    case status
    case info
}

public enum NYCModelDataRequest{
    case locations
    case stationInfo
    case nearest
    case images
}
