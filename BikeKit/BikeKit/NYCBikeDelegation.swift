//
//  NYCBikeDelegation.swift
//  BikeKit
//
//  Created by Joss Manger on 5/15/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import Foundation

@objc
protocol NYCBikeNetworkingDelegate{
    func updated(didUpdate:Bool,str:String?)
    func error(description:String)
    @objc optional func setStations(stationsData:Data)
    @objc optional func setStationsStatus(statusData:Data)
}

public protocol NYCBikeUIDelegate{
    func uiUpdatesAreReady()
    func statusUpdatesAreReady()
    func distancesUpdated(nearestStations:[Nearest])
    func inCooldown(str:String?)
    func error(str:String?)
}
