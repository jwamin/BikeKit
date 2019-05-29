//
//  NYCBikeNetworking.swift
//  BikeKit
//
//  Created by Joss Manger on 5/8/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import CoreLocation

class NYCBikeNetworking : NSObject {
    
    var delegate:NYCBikeNetworkingDelegate?
    
    internal var refreshThrottle:Date = Date() + TimeInterval(-65)
    
    internal var dispatchG:DispatchGroup!
    
    internal var stationInfo:[NYCBikeStationInfo]?
    internal var stationStatus:[NYCBikeStationStatus]?
    
    internal var initial = true
    
    override init() {
        super.init()
        
        dispatchG = DispatchGroup()
        self.getNYCBikeAPIData(task: .info)
        self.getNYCBikeAPIData(task: .status)
        
        print("started requests")
        
        dispatchG.notify(queue: .global()) {
            
            print("requests and parsing done, notifying delegate...")
            
            guard let stationData = self.stationInfo, let stationStatus = self.stationStatus, let delegate = self.delegate else {
                fatalError("this shouldnt happen")
            }
            
            delegate.setStations(stationsData: stationData)
            delegate.setStationsStatus(statusData: stationStatus)
            self.delegate?.updated(didUpdate: true, str: nil)
            self.refreshThrottle = Date()
            self.initial = false
            self.stationInfo = nil
            self.stationStatus = nil
            
        }
        
    }
    
    
    /// Execute request to GBFS endpoint
    ///
    /// - Parameter task: enumeration to request either status or info for bikeshare stations
    func getNYCBikeAPIData(task:NYCBikeRequestType){
        
        let url:URL
        
        switch task{
            case .info:
                url = NYCBikeConstants.URLS.STATION_INFO_URL
            case .status:
                let now = Date()
                if(!checkTimeoutHasExpired(now: now)){
                    throwTimeoutToast(now: now)
                    return
                }
                url = NYCBikeConstants.URLS.STATION_STATUS_URL
        }
        
        let callback:(NYCBikeRequestType,Data)->Void = self.parseData(task:data:)
        
        let stationInfoTask:URLRequest = createRequest(url: url)

        let datatask = createTask(infoTask: stationInfoTask, task: task,callback: callback)

        dispatchG.enter()
        datatask.resume()
        
    }
    
    internal func createTask(infoTask:URLRequest,task:NYCBikeRequestType,callback:@escaping (NYCBikeRequestType,Data)->Void)->URLSessionDataTask{
        
        return URLSession.shared.dataTask(with: infoTask, completionHandler:{
            (data,request,error) in
            
            guard let data = data, error == nil else {
                self.delegate?.error(description: error!.localizedDescription)
                return
            }
            
            callback(task,data)
            
        })
        
    }
    
    
    internal func createRequest(url:URL)->URLRequest{
        return URLRequest(url: url)
    }
    
    
    internal func handleError(error:Error){
        
        self.delegate?.error(description: error.localizedDescription)
        
    }
    
    /// Decides whether to throttle request to refresh
    ///
    /// - Parameter now: current Date
    /// - Returns: true of false dependent on whether to allow the refresh or not
    internal func checkTimeoutHasExpired(now:Date)->Bool{
        let timeout = refreshThrottle + NYCBikeConstants.TIMEOUT_THROTTLE
        if(now<timeout){
            return false
        }
        return true
    }
    
    
    /// Notify UI that the update has not occurred
    ///
    /// - Parameter now: current Date
    internal func throwTimeoutToast(now:Date){
        let timeout = refreshThrottle + NYCBikeConstants.TIMEOUT_THROTTLE
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second]
        formatter.unitsStyle = .full
        formatter.includesApproximationPhrase = true
        let datestr =  formatter.string(from: now, to: timeout)!.lowercased()
        let str = "throttled, try again in \(datestr)"
        DispatchQueue.main.async {
            self.delegate?.updated(didUpdate: false,str: str)
        }
    }
    
}
