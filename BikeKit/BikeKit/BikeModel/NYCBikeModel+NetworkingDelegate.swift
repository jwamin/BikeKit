//
//  NYCBikeModel+UIDelegate.swift
//  BikeKit
//
//  Created by Joss Manger on 5/20/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import Foundation

extension NYCBikeModel : NYCBikeNetworkingDelegate{
    
    public func getNearestStations()->[Nearest]{
        guard let distanceManager = distanceManager else {
            return []
        }
        return distanceManager.nearestStations
    }
    
    
    /// Notification of error from networking stack
    ///
    /// - Parameter description: string describing error in human readable form
    func error(description: String) {
        DispatchQueue.main.async {
            self.delegate?.error(str: description)
        }
    }
    
    
    /// Delegate method that returns the parsed Stations data
    ///
    /// - Parameter stationsData: Array of stations data from networking / parsing stack
    func setStations(stationsData: [NYCBikeStationInfo]) {
        
        self.stationData = stationsData
        
    }
    
    
    /// setStationStatus with data from networking object
    /// take the opportunity to merge the status data with the existing stationData
    /// - Parameter statusData: parsed and structured status data from Networking Stack
    func setStationsStatus(statusData: [NYCBikeStationStatus]) {
        
        let stationStatusData:[NYCBikeStationStatus] = statusData
        
        let stationIDs = self.stationData!.map {
            $0.station_id
        }
        
        var updatedStations = self.stationData
        
        stationStatusData.forEach{ (updatedStation) in
            
            for (index,savedStationID) in stationIDs.enumerated(){
                if updatedStation.station_id == savedStationID {
                    updatedStations![index].status = updatedStation
                }
            }
            
            
        }
        
        self.stationData = updatedStations
        DispatchQueue.main.async {
            self.delegate?.statusUpdatesAreReady()
        }
    }

}
