//
//  NYCBikeModel.swift
//  BikeKit
//
//  Created by Joss Manger on 5/15/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import CoreLocation

public class NYCBikeModel : NSObject{
    
    
    /// Shared User Defaults Suite
    public private(set) static var groupedUserDefaults:UserDefaults = UserDefaults.standard
    
    public var userDefaults:UserDefaults{
        return NYCBikeModel.groupedUserDefaults
    }
    
    public func setUserDefaultsSuite(suite:UserDefaults){
        NYCBikeModel.groupedUserDefaults = suite
        getUserLocationFromDefaults()
    }
    
    
    /// Networking Stack
    internal let networking:NYCBikeNetworking!
    
    public var favourites:[NYCBikeStationInfo]?
    public var locations = [String:CLLocation]()
    public var images = [String:UIImage]()
    public var nearestStations = [Nearest]()
    
    
    public var delegate:NYCBikeUIDelegate?
    
    internal var distanceManager:NYCBikeStationDistanceManager?
    
    internal var previouslyReportedUserLocation:CLLocation? {
        didSet{
            if let gotUserLocation = self.previouslyReportedUserLocation {
                
                //check the updated location isnt jsut the same location
                if let oldvalue = oldValue, let currentValue = self.previouslyReportedUserLocation{
                    
                    if(oldvalue.distance(from: currentValue) < 2.0){
                        return
                    }
                    
                }
                
                setUserLocation(location: gotUserLocation)
                
            }
        }
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
                distanceManager = NYCBikeStationDistanceManager(stationLocations: locations)
                distanceManager?.delegate = self
            } else {
                print("station data updated")
            }
            
        }
    }
    
    public override init() {
        networking = NYCBikeNetworking()
        super.init()
        networking.delegate = self
    }
    
    

    
    public func restartAfterError(){
        if(stationData==nil){
            networking.getNYCBikeAPIData(task: .info)
        }
    }
    
    public func refresh(){
        refreshFavourites()
        updateLocation(userLocation: previouslyReportedUserLocation)
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
        delegate?.uiUpdatesAreReady()
        
    }
    

}
