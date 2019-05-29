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
    
    func nearestStationsUpdated()
    func getStationDataForId(extId:String) -> NYCBikeStationInfo
    
}

public class NYCBikeStationDistanceManager : NSObject {
    
    private var allStations:[NYCBikeStationDistanceModel]
    
    internal var nearestStations = [Nearest]()
    
    var delegate:NYCBikeDistanceReportingDelegate?
    
    private var stationDistancesOrderedArray:[NYCBikeStationDistanceModel]{
        didSet{
            self.orderedArrayUpdated(orderedStations: stationDistancesOrderedArray)
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
    
    private func orderedArrayUpdated(orderedStations: [NYCBikeStationDistanceModel]) {
        
        var nearestStations = [Nearest]()
        for index in 0...NYCBikeConstants.calculateNearestMax{
            if orderedStations.indices.contains(index){
                let orderedStation = orderedStations[index]
                
                guard let stationData = delegate?.getStationDataForId(extId: orderedStation.stationExternalID) else {
                    fatalError()
                }
                let distanceString = "\(Int(orderedStation.distance!))m"
                nearestStations.append(
                    Nearest(externalID: stationData.external_id, info: stationData, distanceString: distanceString, distance: orderedStation.distance!)
                )
                
            }
            
        }
        DispatchQueue.main.async {
            self.nearestStations = nearestStations
            self.delegate?.nearestStationsUpdated()
        }
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


func average(set:[Nearest]) -> Int{
    
    let mean:Int = {
        
        var total = 0
        
        for element in set{
            
            guard let disabledBikes = element.info.status!.num_bikes_disabled, let capacity = element.info.capacity else {
                fatalError()
            }
            
            total += capacity - disabledBikes
        }
        
        let fl = (total / set.count)
        
        return Int(fl)
        
    }()
    
    return mean
    
}
