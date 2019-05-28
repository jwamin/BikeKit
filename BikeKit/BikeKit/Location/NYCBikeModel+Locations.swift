//
//  NYCBikeModel+Locations.swift
//  BikeKit
//
//  Created by Joss Manger on 5/28/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import CoreLocation

extension NYCBikeModel {
    
    internal func setUserLocation(location:CLLocation){
        //Save backgrounded location to userdefaults for use later
        let lat = location.coordinate.latitude
        let lng = location.coordinate.longitude
        let dict = NSDictionary(dictionary: ["lat":lat,"lng":lng])
        NYCBikeModel.groupedUserDefaults.set(dict, forKey: "lastLocation")
    }
    
    internal func getUserLocationFromDefaults(){
        
        if let dictionary = NYCBikeModel.groupedUserDefaults.dictionary(forKey: "lastLocation"){
            
            let lat = dictionary["lat"] as! Double
            let lng = dictionary["lng"] as! Double
            
            let location = CLLocation(latitude: lat, longitude: lng)
            
            print("loading previous location", location)
            previouslyReportedUserLocation = location
            
        }
        
    }
}
