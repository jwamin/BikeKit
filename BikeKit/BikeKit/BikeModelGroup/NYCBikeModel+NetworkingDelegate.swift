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
    
    func setStations(stationsData: Data) {
        
        // reminder - this is how to wind up with [String:Any] from json data
        //let jsonObj = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
        
        do{
            let stationInfoData = try JSONDecoder().decode(NYCStationInfoWrapper.self, from: stationsData)
            guard let stations = stationInfoData.data["stations"] else {
                return
            }
            self.stationData = stations
            networking.getNYCBikeAPIData(task: .status)
        } catch {
            print(error)
        }
        
    }
    
    func setStationsStatus(statusData: Data) {
        var stationStatusData:[NYCBikeStationStatus]?
        
        do{
            let stationInfoData = try JSONDecoder().decode(NYCStationStatusWrapper.self, from: statusData)
            stationStatusData = stationInfoData.data["stations"]!
        } catch {
            print(error)
            fatalError(error.localizedDescription)
        }
        
        guard let stationData = stationStatusData else {
            return
        }
        
        let stationIDs = self.stationData!.map {
            $0.station_id
        }
        
        var updatedStations = self.stationData
        
        stationData.forEach{ (updatedStation) in
            
            for (index,savedStationID) in stationIDs.enumerated(){
                if updatedStation.station_id == savedStationID {
                    updatedStations![index].status = updatedStation
                }
            }
            
            
        }
        
        self.stationData = updatedStations
        print("status set")
//        refreshFavourites()
        delegate?.statusUpdatesAreReady()
    }

}
