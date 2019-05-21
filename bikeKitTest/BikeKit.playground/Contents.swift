import UIKit
import PlaygroundSupport
import BikeKit
import CoreLocation

let str = "BIKEKIT\n=======\n"
print(str)

class TestObject : NSObject, NYCBikeUIDelegate {
    
    let lat = 40.69
    let lng = -73.98
    var location:CLLocation
    
    let userDefaults = UserDefaults.standard
    
    let model:NYCBikeModel
    
    override init() {
        model = NYCBikeModel()
        location = CLLocation(latitude: lat, longitude: lng)
        super.init()
        model.delegate = self
    }
    
    func uiUpdatesAreReady(){
        print("\(model.locations.count) stations from \(NYCBikeConstants.URLS.STATION_INFO_URL)\n")
        
    }
    
    func statusUpdatesAreReady() {
        model.updateLocation(userLocation: location)
    }
    
    func error(str: String?) {
        print(str ?? "error")
    }
    
    func inCooldown(str: String?) {
        print("cooldown \(str ?? "")")
    }
    
    func distancesUpdated(nearestStations: [Nearest]) {
        
        let str = "\nNearest stations\n----------------\n"
        print(str)
        for station in nearestStations.enumerated(){
            print("\(station.offset+1). \(station.element.info.name) \(station.element.distanceString) \n\(station.element.info.smartCapacityAssesmentString(type: .bikes).0) \n\(station.element.info.smartCapacityAssesmentString(type: .docks).0)\n\n")
        }
        
        //model.refresh()
        if let first = nearestStations.first, let status = first.info.status{
            PlaygroundPage.current.finishExecution()
        }

    }
    
}

let testObject = TestObject()

PlaygroundPage.current.needsIndefiniteExecution = true
