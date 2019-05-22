//
//  NYCBikeNetworking.swift
//  BikeKit
//
//  Created by Joss Manger on 5/8/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import CoreLocation

class NYCBikeNetworking : NSObject {
    
    fileprivate(set) var refreshThrottle:Date = Date() + TimeInterval(-65) 

    var delegate:NYCBikeNetworkingDelegate?
    
    override init() {
        super.init()
        self.getNYCBikeAPIData(task: .info)
    }
    
    func getNYCBikeAPIData(task:NYCBikeRequest){
        
        let url:URL
        
        switch task{
            case .info:
                url = NYCBikeConstants.URLS.STATION_INFO_URL
            case .status:
                if(!checkTimeoutHasExpired()){
                    return
                }
                url = NYCBikeConstants.URLS.STATION_STATUS_URL
        }
        
        let callback:(NYCBikeRequest,Data)->Void = self.handleRequest
        
        let stationInfoTask:URLSessionDataTask = URLSession.shared.dataTask(with: url, completionHandler:{
            (data,request,error) in
            
            if (error != nil){
                self.delegate?.error(description: error!.localizedDescription)
            }
            
            guard let data = data else {
                return
            }
            
            if(task == .status){
                self.delegate?.updated(didUpdate: true, str: nil)
                self.refreshThrottle = Date()
            }
            
            callback(task,data)

            
        })
        
        stationInfoTask.resume()
        
    }
    
    func handleRequest(requestType:NYCBikeRequest,data:Data){
        
        switch requestType {
        case .info:
             delegate?.setStations?(stationsData: data)
        case .status:
             delegate?.setStationsStatus?(statusData: data)
        }
        
    }
    
    func handleError(error:Error){
        
        self.delegate?.error(description: error.localizedDescription)
        
    }

    
    private func checkTimeoutHasExpired()->Bool{
        let now = Date()
        let timeout = refreshThrottle + NYCBikeConstants.TIMEOUT_THROTTLE
        if(now<timeout){
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.second]
            formatter.unitsStyle = .full
            formatter.includesApproximationPhrase = true
            let datestr =  formatter.string(from: now, to: timeout)!.lowercased()
            let str = "throttled, try again in \(datestr)"
            DispatchQueue.main.async {
                self.delegate?.updated(didUpdate: false,str: str)
            }
            return false
        }
        return true
    }
    
}
