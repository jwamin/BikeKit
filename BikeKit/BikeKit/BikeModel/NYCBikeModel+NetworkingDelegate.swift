//
//  NYCBikeModel+UIDelegate.swift
//  BikeKit
//
//  Created by Joss Manger on 5/20/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import Foundation

extension NYCBikeModel : NYCBikeNetworkingDelegate{
    
    func error(description: String) {
        delegate?.error(str: description)
    }
    
    func setStations(stationsData: [NYCBikeStationInfo]) {
        
        self.stationData = stationsData
        
    }
    
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
        
        delegate?.statusUpdatesAreReady()
        
    }

}
