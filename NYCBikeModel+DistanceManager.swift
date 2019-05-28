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
        for index in 0...NYCBikeConstants.calculateNearestMax{
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
        
        let distanceClosest = nearest.first!
        print(distanceClosest.distance)
        
        let meanValue = average(set: nearest)
        
        let switchDistance = (query == .docks) ? 2.5 : 1.5
        
        
//        var responses: [HTTPResponse] = [.error(500), .ok, .ok, .error(404), .error(403)]
//        responses.sort {
//            switch ($0, $1) {
//            // Order errors by code
//            case let (.error(aCode), .error(bCode)):
//                return aCode < bCode
//
//            // All successes are equivalent, so none is before any other
//            case (.ok, .ok): return false
//
//            // Order errors before successes
//            case (.error, .ok): return true
//            case (.ok, .error): return false
//            }
//        }
        
        //first sort by numebr of docs
        sorted.sort { (first, second) -> Bool in
            
            let firstAssessment = first.info.smartCapacityAssessmentFloat(type: query, meanSpaces: meanValue)
            let secondAssessment = second.info.smartCapacityAssessmentFloat(type: query, meanSpaces: meanValue)
            
            return firstAssessment>secondAssessment
            
        }
        
        //then sort by distance
        
        sorted.sort { (firstStation,secondStation) in

            return firstStation.distance<secondStation.distance && firstStation.distance < switchDistance * distanceClosest.distance
            
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
