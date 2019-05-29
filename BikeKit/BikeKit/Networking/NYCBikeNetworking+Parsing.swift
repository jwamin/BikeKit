//
//  File.swift
//  BikeKit
//
//  Created by Joss Manger on 5/28/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import Foundation



extension NYCBikeNetworking {
    
    //decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable
    
    func decodeStationData<T>(data:Data,decoderClass:T.Type) throws -> T where T:Decodable{
        do{
            let stationInfoData = try JSONDecoder().decode(decoderClass, from: data)
            return stationInfoData
        } catch {
            throw error
        }
    }
    
    
    
    //    func genericParseData(task:NYCBikeRequestType,data:Data){
    //
    //
    //        // reminder - this is how to wind up with [String:Any] from json data
    //        //let jsonObj = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
    //
    //        let decoderClass:GBFS.Type = NYCStationInfoWrapper.self
    //
    //        var callback:(Decodable)->Void
    //
    //        switch task {
    //            case .info:
    //                var decoderClass = NYCStationInfoWrapper.self
    //                callback = { structure in
    //                    let castStructure = structure as! NYCStationInfoWrapper
    //                    guard let stations = castStructure.data["stations"] else {
    //                        return
    //                    }
    //                    self.delegate?.setStations(stationsData: stations)
    //                }
    //            case .status:
    //                var decoderClass = NYCStationStatusWrapper.self
    //                callback = { structure in
    //                    let castStructure = structure as! NYCStationStatusWrapper
    //                    let stationStatusData = castStructure.data["stations"]!
    //                    self.delegate?.setStationsStatus(statusData: stationStatusData)
    //                }
    //        }
    //
    //        do{
    //            let stationInfoData = try decodeStationData(data: data,decoderClass: decoderClass)
    //            callback(stationInfoData)
    //        } catch {
    //            delegate?.error(description: error.localizedDescription)
    //        }
    //
    //
    //    }
    
    internal func parseData(task:NYCBikeRequestType,data:Data){
        
        // reminder - this is how to wind up with [String:Any] from json data
        //let jsonObj = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
        
        do{
            switch task {
                
            case .info:
                
                let stationInfoData = try decodeStationData(data: data,decoderClass: NYCStationInfoWrapper.self)
                guard let stations = stationInfoData.data["stations"] else {
                    return
                }
                self.stationInfo = stations
                self.dispatchG.leave()
                
            case .status:
                
                let stationInfoData = try decodeStationData(data: data, decoderClass: NYCStationStatusWrapper.self)
                let stationStatusData = stationInfoData.data["stations"]!
                self.stationStatus = stationStatusData
                
                if(initial){
                    self.dispatchG.leave()
                } else {
                    delegate?.setStationsStatus(statusData: stationStatusData)
                    self.delegate?.updated(didUpdate: true, str: nil)
                    self.refreshThrottle = Date()
                }
                
            }
        } catch {
            delegate?.error(description: error.localizedDescription)
        }
        
        return
    }
    
}
