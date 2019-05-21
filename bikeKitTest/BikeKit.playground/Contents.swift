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
        for (index,station) in nearestStations.enumerated(){
            print("\(index+1). \(station.info.name) \(station.distanceString) \n\(station.info.smartCapacityAssesmentString(type: .bikes).0) \n\(station.info.smartCapacityAssesmentString(type: .docks).0)\n\n")
        }
        
        print("Smart ordering for bikes\n")
        for reordered in NYCBikeModel.smartOrderingOfNearestStations(nearestStations,query:.bikes) {
            print(reordered.info.name+" \(reordered.distanceString) \(reordered.info.status!.num_bikes_available) bikes available\n")
        }
        print("\n\n")
        print("Smart ordering for docks\n")
        for reordered in NYCBikeModel.smartOrderingOfNearestStations(nearestStations,query:.docks) {
            print(reordered.info.name+" \(reordered.distanceString) \(reordered.info.status!.num_docks_available) / \(reordered.info.capacity - reordered.info.status!.num_bikes_disabled) docks available \n")
        }
        
        //model.refresh()
        if let first = nearestStations.first, let _ = first.info.status{
            PlaygroundPage.current.finishExecution()
        }

    }
    
}

let testObject = TestObject()

PlaygroundPage.current.needsIndefiniteExecution = true
