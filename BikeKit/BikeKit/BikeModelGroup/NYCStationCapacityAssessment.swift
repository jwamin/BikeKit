//
//  NYCStationCapacityAssessment.swift
//  BikeKit
//
//  Created by Joss Manger on 5/20/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import Foundation

extension NYCBikeStationInfo {
    
    internal func smartCapacityAssessment(type:NYCBikeStationCapacityQuery)->Float{
        
        guard let status = self.status else {
            return 0
        }
        let capacity = Float(self.capacity);
        switch type {
        case .bikes:
            return Float(status.num_bikes_available) / capacity
        case .docks:
            return Float(status.num_docks_available) / capacity
        }
        
    }
    
    
    public func smartCapacityAssesmentString(type:NYCBikeStationCapacityQuery)->String{
        
        let indicativeFloat = smartCapacityAssessment(type: type)
        
        
        switch indicativeFloat {
        case 0.0:
            return "Bad for \(type.rawValue.capitalized)"
        case let _ where indicativeFloat > 0.50:
            return "Good for \(type.rawValue.capitalized)"
        case let _ where indicativeFloat > 0.25:
            return "Not Great for \(type.rawValue.capitalized)"
        case let _ where indicativeFloat < 0.25:
            return "Try another station for \(type.rawValue.capitalized)"
        default:
            return "Unknown for \(type.rawValue.capitalized)"
        }
        
        
    }
    
    
}

public enum NYCBikeStationCapacityQuery : String{
    case bikes = "bikes"
    case docks = "docks"
}

enum NYCStationCapacityAssessment{
    case good
    case low
    case empty
}
