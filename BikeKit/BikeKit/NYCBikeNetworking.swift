//
//  NYCBikeNetworking.swift
//  BikeKit
//
//  Created by Joss Manger on 5/8/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import CoreLocation

class NYCBikeNetworking : NSObject {
    
    //URLs
    static let ALL_DATA_URL = URL(string:"https://gbfs.citibikenyc.com/gbfs/gbfs.json")!
    static let STATION_INFO_URL = URL(string:"https://gbfs.citibikenyc.com/gbfs/en/station_information.json")!
    static let STATION_STATUS_URL = URL(string:"https://gbfs.citibikenyc.com/gbfs/en/station_status.json")!
    
    fileprivate(set) var refreshThrottle:Date = Date() + TimeInterval(-65) {
        didSet{
            print("changed from \(oldValue) to \(refreshThrottle)")
            print("changed time")
        }
    }

    var delegate:NYCBikeNetworkingDelegate?
    
    override init() {
        super.init()
        self.getNYCBikeAPIData(task: .info)
    }
    
    func getNYCBikeAPIData(task:NYCBikeRequest){
        
        let url:URL
        
        switch task{
            case .info:
                url = NYCBikeNetworking.STATION_INFO_URL
            case .status:
                if(!checkTimeoutHasExpired()){
                    return
                }
                url = NYCBikeNetworking.STATION_STATUS_URL
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
        let timeout = refreshThrottle + TIMEOUT_THROTTLE
        print(now,timeout,timeout>now)
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
