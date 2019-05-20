//
//  NYCBikeModelDistanceManager.swift
//  BikeKit
//
//  Created by Joss Manger on 5/20/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import CoreLocation

extension NYCBikeModel : NYCBikeDistanceReportingDelegate {

    public func updateLocation(userLocation:CLLocation?){
     print("update location called", userLocation)
        if let userlocation = userLocation{
            previouslyReportedUserLocation = userlocation
        }
        
        guard let dmanager = distanceManager else {
            
            return
            
        }
        
        guard let userlocation = previouslyReportedUserLocation else {
            return
        }
        dmanager.userLocation = userlocation
        
    }
    
    public func orderedArrayUpdated(orderedStations: [NYCBikeStationDistanceModel]) {
        var nearestStations = [Nearest]()
        for index in 0...3{
            if orderedStations.indices.contains(index){
                let orderedStation = orderedStations[index]
                
                guard let mainStationInfo = stationData?.filter({ (station) -> Bool in
                    station.external_id == orderedStation.stationExternalID
                }).first else {
                    continue
                }
                let distanceString = "\(Int(orderedStation.distance!))m"
                nearestStations.append(
                    Nearest(externalID: mainStationInfo.external_id, info: mainStationInfo, distanceString: distanceString)
                )
                
            }
            
        }
        DispatchQueue.main.async {
            self.delegate?.distancesUpdated(nearestStations:nearestStations)
        }
    }
    
   
    
}

public struct Nearest {
    public let externalID:String
    public let info:NYCBikeStationInfo
    public let distanceString:String
}
