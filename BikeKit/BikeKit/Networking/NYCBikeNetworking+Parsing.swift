//
//  File.swift
//  BikeKit
//
//  Created by Joss Manger on 5/28/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import Foundation

extension NYCBikeNetworking {
    
    func decodeStationData<T:Decodable>(data:Data,decoderClass:T.Type) throws -> T{
        do{
            let stationInfoData = try JSONDecoder().decode(decoderClass.self, from: data)
            return stationInfoData
        } catch {
            throw error
        }
    }
    
//    func parseData(task:NYCBikeRequestType,data:Data){
//
//
//        // reminder - this is how to wind up with [String:Any] from json data
//        //let jsonObj = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
//
//        var decoderClass:Decodable.Type
//
//        switch task {
//            case .info:
//                decoderClass = NYCStationInfoWrapper.self
//            case .status:
//                decoderClass = NYCStationStatusWrapper.self
//        }
//
//        do{
//            let stationInfoData = try decodeStationData(data: data,decoderClass: decoderClass)
//            guard let stations = stationInfoData.data["stations"] else {
//                return
//            }
//            self.stationData = stations
//        } catch {
//            delegate?.error(description: error.localizedDescription)
//        }
//
//
//    }
    
    func parseData(task:NYCBikeRequestType,data:Data){
        
        
        // reminder - this is how to wind up with [String:Any] from json data
        //let jsonObj = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
        
        switch task {
        case .info:
            do{
                let stationInfoData = try decodeStationData(data: data,decoderClass: NYCStationInfoWrapper.self)
                guard let stations = stationInfoData.data["stations"] else {
                    return
                }
                delegate?.setStations(stationsData: stations)
            } catch {
                delegate?.error(description: error.localizedDescription)
            }
            return
        case .status:
            do{
                let stationInfoData = try decodeStationData(data: data, decoderClass: NYCStationStatusWrapper.self)
                let stationStatusData = stationInfoData.data["stations"]!
                delegate?.setStationsStatus(statusData: stationStatusData)
            } catch {
                delegate?.error(description: error.localizedDescription)
            }
            return
        }
        
        
        
        
    }
    
}
