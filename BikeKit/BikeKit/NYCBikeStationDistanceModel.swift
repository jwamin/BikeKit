//
//  NYCBikeStationDistanceModel.swift
//  BikeKit
//
//  Created by Joss Manger on 5/20/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import Foundation
import CoreLocation

public protocol NYCBikeDistanceModelProtocol{
    var stationLocation:CLLocation{
        get
    }
    var userLocation:CLLocation?{
        get set
    }
    var distance:CLLocationDistance?{
        get
    }
}

public protocol NYCBikeDistanceReportingDelegate {
    
    func orderedArrayUpdated(orderedStations:[NYCBikeStationDistanceModel])
    
}

public class NYCBikeStationDistanceManager : NSObject {
    
    var allStations:[NYCBikeStationDistanceModel]
    
    var delegate:NYCBikeDistanceReportingDelegate?
    
    var stationDistancesOrderedArray:[NYCBikeStationDistanceModel]{
        didSet{
            delegate?.orderedArrayUpdated(orderedStations: stationDistancesOrderedArray)
        }
    }
    
    init(stationLocations:[String:CLLocation]) {
        
        self.allStations = stationLocations.map({ (key,location) -> NYCBikeStationDistanceModel in
            return NYCBikeStationDistanceModel(stationExternalId: key, stationLocation: location)
        })
        
        stationDistancesOrderedArray = []
    }
    
    var userLocation:CLLocation? {
        didSet{
            allStations.forEach { (distanceModel) in
                distanceModel.userLocation = self.userLocation
                distanceModel.calculateDistance()
            }
            orderArray()
        }
    }
    
    func orderArray(){
        
        var stationsWithDistances = allStations.filter { (distanceModel) -> Bool in
            return distanceModel.distance != nil
        }
        
        stationsWithDistances.sort { (first, second) -> Bool in
            first.distance!<second.distance!
        }
        
        stationDistancesOrderedArray = stationsWithDistances
        
    }
    
}


public class NYCBikeStationDistanceModel : NSObject, NYCBikeDistanceModelProtocol{
    
    public let stationLocation:CLLocation
    let stationExternalID:String
    public var userLocation:CLLocation? {
        didSet{
            calculateDistance()
        }
    }
    
    public var distance:CLLocationDistance?
    
    init(stationExternalId:String,stationLocation:CLLocation) {
        self.stationExternalID = stationExternalId
        self.stationLocation = stationLocation
        super.init()
    }
    
    internal func calculateDistance(){
        guard let user = userLocation else {
            return
        }
        
        distance = stationLocation.distance(from: user)
        
    }
    
}
