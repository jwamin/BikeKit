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
    
    var dispatchG:DispatchGroup!
    
    override init() {
        super.init()
        
        dispatchG = DispatchGroup()
        self.getNYCBikeAPIData(task: .info)
        self.getNYCBikeAPIData(task: .status)
        
        dispatchG.notify(queue: .global()) {
            print("done")
        }
        
    }
    
    func getNYCBikeAPIData(task:NYCBikeRequestType){
        
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
        
        let callback:(NYCBikeRequestType,Data)->Void = self.parseData(task:data:)
        
        let stationInfoTask:URLRequest = createRequest(url: url)

        let datatask = createTask(infoTask: stationInfoTask, task: task,callback: callback)

        dispatchG.enter()
        datatask.resume()
        
    }
    
    public func createTask(infoTask:URLRequest,task:NYCBikeRequestType,callback:@escaping (NYCBikeRequestType,Data)->Void)->URLSessionDataTask{
        
        return URLSession.shared.dataTask(with: infoTask, completionHandler:{
            (data,request,error) in
            
            guard let data = data, error == nil else {
                self.delegate?.error(description: error!.localizedDescription)
                return
            }
            
            if(task == .status){
                self.delegate?.updated(didUpdate: true, str: nil)
                self.refreshThrottle = Date()
            }
            
            self.dispatchG.leave()
            callback(task,data)
            
        })
        
    }
    
    public func createRequest(url:URL)->URLRequest{
        return URLRequest(url: url)
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
