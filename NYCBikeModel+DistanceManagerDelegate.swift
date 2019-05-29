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
            print("no dmanager")
            return
        }
        
        guard let userlocation = previouslyReportedUserLocation else {
            print("no user location")
            return
        }
        print("user location set")
        dmanager.userLocation = userlocation
        
    }
    
    public func nearestStationsUpdated() {
        delegate?.distancesUpdated(nearestStations: self.getNearestStations())
    }
    
    public func getStationDataForId(extId: String) -> NYCBikeStationInfo {
        
        guard let stationData = stationData?.first(where: { (info) -> Bool in
            info.external_id == extId
        }) else {
            fatalError("nothing with the id\(extId)")
        }
        
        return stationData
        
    }
    
    public static func smartOrderingOfNearestStations(_ nearest:[Nearest],query:NYCBikeStationCapacityQuery)->[Nearest]{
        
        var sorted = nearest
        
        let distanceClosest = nearest.first!
        
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
