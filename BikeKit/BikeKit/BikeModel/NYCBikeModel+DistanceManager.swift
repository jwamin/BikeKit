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
                    Nearest(externalID: mainStationInfo.external_id, info: mainStationInfo, distanceString: distanceString, distance: orderedStation.distance!)
                )
                
            }
            
        }
        DispatchQueue.main.async {
            self.nearestStations = nearestStations
            self.delegate?.distancesUpdated(nearestStations:nearestStations)
        }
    }
    
    public static func smartOrderingOfNearestStations(_ nearest:[Nearest],query:NYCBikeStationCapacityQuery)->[Nearest]{
        
        var sorted = nearest
        
        sorted.sort { (first, second) -> Bool in
            
            let firstAssessment = first.info.smartCapacityAssessment(type: query)
            let secondAssessment = second.info.smartCapacityAssessment(type: query)
            
//            if (query == .docks){
//                //docks queried, so we can potentially travel slightly further
//                if(!(second.distance<(first.distance * 2.0))){
//                    print("dock station further than twice the distance to nearest \(second.info.short_name)")
//                    return false
//                }
//            } else {
//                if(!(second.distance<(first.distance * 1.5))){
//                    print("bike station further than 1.5 the distance to nearest \(second.info.short_name)")
//                    return false
//                }
//            }
            
            if(firstAssessment>secondAssessment){
                return true
            }
            
//            if(firstAssessment == .low && secondAssessment == .good){
//                return true
//            }
//            if(firstAssessment == .empty && secondAssessment == .low){
//                return true
//            }
            
            return false
            
        }
        
        return sorted
        
    }
    
}

public struct Nearest {
    public let externalID:String
    public let info:NYCBikeStationInfo
    public let distanceString:String
    public let distance:Double
}
