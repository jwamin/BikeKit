//
//  NYCBikeModel.swift
//  BikeKit
//
//  Created by Joss Manger on 5/15/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import CoreLocation

public class NYCBikeModel : NSObject, NYCBikeNetworkingDelegate{
    
    public static var groupedUserDefaults:UserDefaults? = nil
    
    private let networking:NYCBikeNetworking!
    
    public var favourites:[NYCBikeStationInfo]?
    public var locations = [String:CLLocation]()
    public var images = [String:UIImage]()
    
    public var delegate:NYCBikeUIDelegate?
    
    public override init() {
        networking = NYCBikeNetworking()
        super.init()
        networking.delegate = self
    }
    
    
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
        
        refreshFavourites()
        DispatchQueue.main.async {
            self.delegate?.updated()
        }
    }
    
    

    
    
    public func refreshFavourites(_ callback:((BikeNetworkingError?)->Void)? = nil) {
        
        guard let stationData = self.stationData else {
            
            if let callback = callback{
                callback(.failed)
            }
            
            return
        }
        
        var matches = [NYCBikeStationInfo]()
        
        let savedFavourites = NYCBikeModel.groupedUserDefaults!.array(forKey: "favourites") as? [String] ?? []
        
        for id in savedFavourites{
            
            if let stationHit = stationData.first(where: { (info) -> Bool in
                info.station_id == id }) {
                matches.append(stationHit)
                images.removeValue(forKey: id)
            }
            
        }
        
        let testorder = matches.map{
            $0.station_id
        }
        
        //order by saved favourites
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
        
        guard let groupDefaults = NYCBikeModel.groupedUserDefaults else {
            fatalError()
        }
        
        let favourites:[String] = groupDefaults.array(forKey: "favourites") as? [String] ?? []
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
        
        
        groupDefaults.set(newFavourites, forKey: "favourites")
        groupDefaults.synchronize()
        
        return add
        
    }
    
    public func updateFavouriteToRow(id:String,newRowIndex:Int)->Bool{
        
        guard let groupDefaults = NYCBikeModel.groupedUserDefaults else {
            fatalError()
        }
        
        let favourites:[String] = groupDefaults.array(forKey: "favourites") as? [String] ?? []
        var newFavourites = favourites
        guard let index = newFavourites.firstIndex(of: id) else {
            return false
        }
        
        newFavourites.remove(at: index)
        
        newFavourites.insert(id, at: newRowIndex)
        
        
        groupDefaults.set(newFavourites, forKey: "favourites")
        groupDefaults.synchronize()
        
        print(favourites, id)
        print(newFavourites)
        
        return true
    }
    
    public func refresh(){
        refreshFavourites()
        self.networking.getNYCBikeAPIData(task: .status)
    }
    
    func updated(didUpdate: Bool,str:String? = "") {
        
        //update failed probably because of throttling
        if(!didUpdate){
            if let messageString = str{
                delegate?.inCooldown(str: messageString)
            }
            return
        }
        
        //updated succeeded... now what?
        delegate?.updated()
        
    }
    

}
