//
//  MapViewController.swift
//  bikeKitTest
//
//  Created by Joss Manger on 5/8/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit
import MapKit
import BikeKit
import BikeKitUI

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    let model = AppDelegate.mainBikeModel
    let location = AppDelegate.locationManager
    var map:MKMapView!

    var zoomToLocation = false
    
    private var userInitialZoomSet:Bool = false
    
    var pins = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Map"
        map = MKMapView(frame: self.view.frame)
        map.autoresizingMask = [.flexibleWidth,.flexibleWidth]
        view.addSubview(map)
        
        
        map.delegate = self
        map.register(MKPointAnnotation.self, forAnnotationViewWithReuseIdentifier: "id")
        map.showsUserLocation = true
        location.delegate = self
        location.desiredAccuracy = kCLLocationAccuracyHundredMeters
        location.startUpdatingLocation()
        
        addPins()
        // Do any additional setup after loading the view.
    }
    
    func addPins(){

        //update existing pins, if any

        for (index,pin) in pins.enumerated().reversed(){
            let point = MKMapPoint(pin.coordinate)
            if(!map.visibleMapRect.contains(point)){
                pins.remove(at: index)
                map.removeAnnotation(pin)
            }
        }
        
        
        for station in model.locations{
            
            var mainStationObject:NYCBikeStationInfo?
            
            for savedStation in model.stationData!{
                
                if savedStation.external_id == station.key{
                    mainStationObject = savedStation
                    break
                }
                
            }
            
            //Skip as often as possible!
            
            //if the point is outside of the map rect, skip!
            let point = MKMapPoint(station.value.coordinate)
            if(!map.visibleMapRect.contains(point)){
                continue
            }
            
            //if the existing pin coordinate is the same as the loop variable, skip
            if pins.contains(where: { (pin) -> Bool in
                MKMapPointEqualToPoint(point, MKMapPoint(pin.coordinate))
            }){
                continue
            }
            
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = point.coordinate

            
            guard let stationObjectForPoint = mainStationObject else {
                print("continuing")
                continue
            }
            
            annotation.title = stationObjectForPoint.name
          
            
            annotation.subtitle = stationObjectForPoint.statusString()
            
            
            pins.append(annotation)
           
            
            
        }
        
         map.addAnnotations(pins)
        
    }
    
    func zoomToStation(station:NYCBikeStationInfo){
        guard let location = model.locations[station.external_id] else {
            return
        }
        zoomToLocation = true
        print("zoom to station")
        zoomToLocation(location: location.coordinate)
    }
    
    func zoomToUser(){
        print("zoom to user")
        zoomToLocation(location: map.userLocation.coordinate)
    }
    
    func zoomToLocation(location:CLLocationCoordinate2D){
        //self.loadViewIfNeeded()
        var region = MKCoordinateRegion()
        region.center = location
        region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        map.setRegion(region, animated: true)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(!zoomToLocation){
            zoomToUser()
        }
        zoomToLocation = false
    }
    
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        if(!userInitialZoomSet){
        print("initial zoom to user")
            userInitialZoomSet = true
            zoomToUser()
            
        }
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("region changed")
        addPins()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
