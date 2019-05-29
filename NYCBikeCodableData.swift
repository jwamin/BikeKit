//
//  NYCBikeCodableData.swift
//  BikeKit
//
//  Created by Joss Manger on 5/15/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import Foundation

//TODO: update structures to reflect optional attributes on https://github.com/NABSA/gbfs/blob/master/gbfs.md

protocol GBFS : Codable { }

struct NYCStationInfoWrapper : GBFS {
    let last_updated:Date
    let data:[String:[NYCBikeStationInfo]]
}

struct NYCStationStatusWrapper : GBFS{
    let last_updated:Date
    let data:[String:[NYCBikeStationStatus]]
}

public struct NYCBikeStationInfo:GBFS {
    
    public let station_id:String
    public let external_id:String
    public let name:String
    public let short_name:String?
    public let lat:Double
    public let lon:Double
    public let region_id:Int?
    public let rental_methods:[RentalMethods]
    public let capacity:Int?
    public let rental_url:URL
    public let electric_bike_surcharge_waiver:Bool
    public let eightd_has_key_dispenser:Bool
    public var status:NYCBikeStationStatus?
    
    public func statusString()->String{
        guard let status = self.status else {
            return ""
        }
        return "bikes available: \(status.num_bikes_available), docks: \(status.num_docks_available), disabled: \(status.num_bikes_disabled!), electric bikes avalable: \(status.num_ebikes_available), electric bike waiver: \(self.electric_bike_surcharge_waiver)"
    }
    
}

public enum RentalMethods : String, GBFS {
    case key = "KEY"
    case creditCard = "CREDITCARD"
    case paypass = "PAYPASS"
    case applePay = "APPLEPAY"
    case androidPay = "ANDROIDPAY"
    case transitCard = "TRANSITCARD"
    case accountNumber = "ACCOUNTNUMBER"
    case phone = "PHONE"
}

//{"station_id":"304","num_bikes_available":6,"num_ebikes_available":0,"num_bikes_disabled":1,"num_docks_available":26,"num_docks_disabled":0,"is_installed":1,"is_renting":1,"is_returning":0,"last_reported":1557248000,"eightd_has_available_keys":true,"eightd_active_station_services":[{"id":"a58d9e34-2f28-40eb-b4a6-c8c01375657a"}]},

public struct NYCBikeStationStatus : GBFS{
    
    public let station_id:String
    public let num_bikes_available:Int
    public let num_ebikes_available:Int
    public let num_bikes_disabled:Int?
    public let num_docks_disabled:Int?
    public let num_docks_available:Int
    public let is_installed:Int
    public let is_renting:Int
    public let is_returning:Int
    public let last_reported:Date
    
}


