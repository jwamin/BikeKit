//
//  NYCBikeModel+Fevourites.swift
//  BikeKit
//
//  Created by Joss Manger on 5/21/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import Foundation

extension NYCBikeModel {
    
    public func refreshFavourites(_ callback:((BikeNetworkingError?)->Void)? = nil) {
        
        guard let stationData = self.stationData else {
            
            if let callback = callback{
                callback(.failed)
            }
            
            return
        }
        
        var matches = [NYCBikeStationInfo]()
        
        let savedFavourites = NYCBikeModel.groupedUserDefaults.array(forKey: "favourites") as? [String] ?? []
        
        for id in savedFavourites{
            
            if let stationHit = stationData.first(where: { (info) -> Bool in
                info.station_id == id }) {
                matches.append(stationHit)
                images.removeValue(forKey: id)
            }
            
        }
        
        //order by saved favourites
        self.favourites = matches
        
        guard let callback = callback else {
            DispatchQueue.main.async {
                self.delegate?.uiUpdatesAreReady()
            }
            return
        }
        
        callback(nil)
        
    }
    
    public func isFavourite(extID: String)->Bool{
    
        if let _ = self.favourites?.first(where: { (info) -> Bool in
            info.external_id == extID
        }) {
            return true
        }
        return false
    }
    
    
    /// Toggle favourite with external Id
    ///
    /// - Parameter extId: the external
    /// - Returns: forwarded result of favouriting transaction
    public func toggleFavouriteWithExternalId(extId:String)->Bool{
        
        let match = self.getStationDataForId(extId: extId)
        
        return toggleFavouriteForId(id: match.station_id)
    }
    
    
    /// Toggle favourite
    /// Checks for favourite status in userDefaults suite and updates by negating that value
    ///
    /// - Parameter id: stationID Int string
    /// - Returns: Bool status of isFavourite the result of favouriting transaction
    public func toggleFavouriteForId(id:String)->Bool{
        
        let groupDefaults = NYCBikeModel.groupedUserDefaults
        
        let favourites:[String] = groupDefaults.array(forKey: NYCBikeConstants.favouritesUserDefaultsKey) as? [String] ?? []
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
        
        groupDefaults.set(newFavourites, forKey: NYCBikeConstants.favouritesUserDefaultsKey)
        groupDefaults.synchronize()
        
        print("\(id) \((add) ? "added":"removed")")
        return add
        
    }
    
    public func updateFavouriteToRow(id:String,newRowIndex:Int)->Bool{
        
        let groupDefaults = NYCBikeModel.groupedUserDefaults
        
        let favourites:[String] = groupDefaults.array(forKey: NYCBikeConstants.favouritesUserDefaultsKey) as? [String] ?? []
        var newFavourites = favourites
        guard let index = newFavourites.firstIndex(of: id) else {
            return false
        }
        
        //update model
        newFavourites.remove(at: index)
        newFavourites.insert(id, at: newRowIndex)
        
        groupDefaults.set(newFavourites, forKey: NYCBikeConstants.favouritesUserDefaultsKey)
        groupDefaults.synchronize()
        
        print(favourites, id)
        print(newFavourites)
        
        return true
    }
}
