//
//  NYCBikeNetworking.swift
//  BikeKit
//
//  Created by Joss Manger on 5/8/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import CoreLocation

//FAO
let duffieldWilloughby = 390
let jayYork = 3674

let dummyData = [duffieldWilloughby,jayYork]

public class NYCBikeNetworking : NSObject {
    
    static let ALL_DATA_URL = URL(string:"https://gbfs.citibikenyc.com/gbfs/gbfs.json")!
    static let STATION_INFO_URL = URL(string:"https://gbfs.citibikenyc.com/gbfs/en/station_information.json")!
    static let STATION_STATUS_URL = URL(string:"https://gbfs.citibikenyc.com/gbfs/en/station_status.json")!
    
    public static var groupedUserDefaults:UserDefaults? = nil
    
    
    public fileprivate(set) var refreshThrottle:Date = Date() + TimeInterval(-65) {
        didSet{
            print("changed from \(oldValue) to \(refreshThrottle)")
            print("changed time")
        }
    }

    
    public var delegate:NYCBikeNetworkingDelegate?
    
    public var stationData:[NYCBikeStationInfo]?{
        didSet{
            if(oldValue == nil){
            guard let stationData = self.stationData else {
                return
            }
            for station in stationData{
                if(locations[station.external_id] == nil){
                    locations[station.external_id] = CLLocation(latitude: CLLocationDegrees(station.lat), longitude: CLLocationDegrees(station.lon))
                }
            }
            
            } else {
                print("station data updated")
            }

            
            
        }
    }
    
    public var favourites:[NYCBikeStationInfo]?
    
    public var locations = [String:CLLocation]()
    
    
    public override init() {
        super.init()
        self.getNYCBikeAPIData(task: .info)
    }
    
    
    
    public func getNYCBikeAPIData(task:NYCBikeRequest){
        
        let url:URL
        let callback:(Data)->Void
        switch task{
        case .info:
            url = NYCBikeNetworking.STATION_INFO_URL
            callback = self.handleInfoRequest
        case .status:
            url = NYCBikeNetworking.STATION_STATUS_URL
            callback = self.handleStatusRequest
            let now = Date()
            let timeout = refreshThrottle + TimeInterval(60)
            print(now,timeout,timeout>now)
            if(now<timeout){
                let str = "throttled, try again at\n \(timeout)"
                print(str)
                DispatchQueue.main.async {
                    self.delegate?.inCooldown(str: str)
                }
                return
            }
        }
        
        let stationInfoTask:URLSessionDataTask = URLSession.shared.dataTask(with: url, completionHandler:{
            (data,request,error) in
            if (error != nil){
                fatalError(error?.localizedDescription ?? "error")
            }
            
            guard let data = data, let jsonString = String(data: data, encoding: .utf8) else {
                return
            }
            
            callback(data)
            
        })
        
        stationInfoTask.resume()
        
    }
    
    func handleInfoRequest(data:Data){
        
        
        var stationData:[NYCBikeStationInfo]?
        
        //let jsonObj = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
        do{
            let stationInfoData = try JSONDecoder().decode(NYCStationInfoWrapper.self, from: data)
            stationData = stationInfoData.data["stations"]!
        } catch {
            print(error)
        }
        
        self.stationData = stationData
        
        getNYCBikeAPIData(task: .status)
        
    }
    
    func handleStatusRequest(data:Data){
        
        
        var stationStatusData:[NYCBikeStationStatus]?
        
        //print(String(data: data, encoding: .utf8)!)
        
        //let jsonObj = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
        do{
            let stationInfoData = try JSONDecoder().decode(NYCStationStatusWrapper.self, from: data)
            stationStatusData = stationInfoData.data["stations"]!
        } catch {
            print(error)
            fatalError(error.localizedDescription)
        }
        
        guard let stationData = stationStatusData else {
            return
        }
        
        //var favouritesInfo = [NYCBikeStationStatus]()
        
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
        
        refreshThrottle = Date()
        assembleDataForFavourites()
        DispatchQueue.main.async {
            self.delegate?.updated()
        }
        
    }
    
    
    
    
    public func assembleDataForFavourites(_ callback:((BikeNetworkingError?)->Void)? = nil) {
        
        guard let stationData = self.stationData else {
            
            if let callback = callback{
                callback(.failed)
            }
            
            return
        }
        
        var matches = [NYCBikeStationInfo]()
        
        let savedFavourites = NYCBikeNetworking.groupedUserDefaults!.array(forKey: "favourites") as? [String] ?? []
        let intsavedFavourites:[Int] = savedFavourites.compactMap {
            Int($0)
        }
        

        stationData.forEach {
            for id in intsavedFavourites {
                if $0.station_id == String(id){
                    matches.append($0)
                }
            }
        }
        
        self.favourites = matches
        
        guard let callback = callback else {
            DispatchQueue.main.async {
                self.delegate?.updated()
            }
            return
        }
        
       callback(nil)
        
    }
    
    public func toggleFavouriteForId(id:String)->Bool{
        
        let favourites:[String] = NYCBikeNetworking.groupedUserDefaults!.array(forKey: "favourites") as? [String] ?? []
        var newFavourites = favourites
        var add = false
        if(favourites.contains(id)){
            //we are removing favourite
            for (index,fav) in favourites.enumerated().reversed(){
                if fav == id{
                    newFavourites.remove(at: index)
                }
            }
            
        } else {
            //we are adding a favourite
            newFavourites.append(id)
            add = true
        }
        
        
        NYCBikeNetworking.groupedUserDefaults!.set(newFavourites, forKey: "favourites")
        
        return add
        
    }
    
    public func refresh(){
        assembleDataForFavourites()
        self.getNYCBikeAPIData(task: .status)
    }
    
}

public enum BikeNetworkingError : Error{
    case throttled
    case newData
    case failed
}

struct NYCStationInfoWrapper : Codable {
    let last_updated:Date
    let data:[String:[NYCBikeStationInfo]]
}

struct NYCStationStatusWrapper : Codable{
    let last_updated:Date
    let data:[String:[NYCBikeStationStatus]]
}

public struct NYCBikeStationInfo:Codable {
    
    public let station_id:String
    public let external_id:String
    public let name:String
    public let short_name:String
    public let lat:Double
    public let lon:Double
    public let region_id:Int
    public let rental_methods:[RentalMethods]
    public let capacity:Int
    public let rental_url:URL
    public let electric_bike_surcharge_waiver:Bool
    public let eightd_has_key_dispenser:Bool
    public var status:NYCBikeStationStatus?
    
    public func statusString()->String{
        guard let status = self.status else {
            return ""
        }
        return "bikes available: \(status.num_bikes_available), docks: \(status.num_docks_available), disabled: \(status.num_bikes_disabled), electric bikes avalable: \(status.num_ebikes_available), electric bike waiver: \(self.electric_bike_surcharge_waiver)"
    }
    
}

public enum RentalMethods : String, Codable {
    case key = "KEY"
    case creditCard = "CREDITCARD"
}

//{"station_id":"304","num_bikes_available":6,"num_ebikes_available":0,"num_bikes_disabled":1,"num_docks_available":26,"num_docks_disabled":0,"is_installed":1,"is_renting":1,"is_returning":0,"last_reported":1557248000,"eightd_has_available_keys":true,"eightd_active_station_services":[{"id":"a58d9e34-2f28-40eb-b4a6-c8c01375657a"}]},

public struct NYCBikeStationStatus : Codable{
    
    public let station_id:String
    public let num_bikes_available:Int
    public let num_ebikes_available:Int
    public let num_bikes_disabled:Int
    public let num_docks_available:Int
    public let is_installed:Int
    public let is_renting:Int
    public let is_returning:Int
    public let last_reported:Date
    
}

public enum NYCBikeRequest{
    case status
    case info
}


public protocol NYCBikeNetworkingDelegate{
    func updated()
    func inCooldown(str:String?)
}
