//
//  NYCStationCapacityAssessment.swift
//  BikeKit
//
//  Created by Joss Manger on 5/20/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import Foundation

extension NYCBikeStationInfo {
    
    internal func smartCapacityAssessmentFloat(type:NYCBikeStationCapacityQuery,meanSpaces:Int? = nil)->Float{
        
        guard let status = self.status else {
            return 0
        }
        
        let capacity = (meanSpaces != nil) ? Float(meanSpaces!) : Float(self.capacity - self.status!.num_bikes_disabled);
        
        switch type {
            case .bikes:
                return Float(status.num_bikes_available) / capacity
            case .docks:
                return Float(status.num_docks_available) / capacity
        }
        
    }
    
    
    public func smartCapacityAssesment(type:NYCBikeStationCapacityQuery,set:[Nearest]? = nil)->(String,NYCStationCapacityAssessment){
        
        var meanValue:Int?
        if let set = set{
            meanValue = average(set: set)
        }
        
        let indicativeFloat = smartCapacityAssessmentFloat(type: type, meanSpaces: meanValue)
    
        return NYCStationCapacityAssessment.calculateResponse(type: type, indicativeFloat: indicativeFloat)
        
    }
    
    
}

public enum NYCBikeStationCapacityQuery : String{
    case bikes = "bike"
    case docks = "dock"
}

public enum NYCStationCapacityAssessment{
    case good
    case ok
    case low
    case empty
    case unknown
    static func calculateResponse(type:NYCBikeStationCapacityQuery,indicativeFloat:Float)->(String,NYCStationCapacityAssessment){
        switch indicativeFloat {
        case 0.0:
            return ("This station is out of \(type.rawValue)s",.empty)
        case _ where indicativeFloat > 0.75:
            return ("Good for \(type.rawValue.capitalized)s",.good)
        case _ where indicativeFloat > 0.25:
            return ("You'll probably find a \(type.rawValue)",.ok)
        case _ where indicativeFloat < 0.25:
            return ("Try another station for \(type.rawValue)s",.low)
        default:
            return ("Unknown for \(type.rawValue.capitalized)s",.unknown)
        }
    }
    
}
