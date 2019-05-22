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

class MapViewController: UIViewController, MKMapViewDelegate {

    let model = AppDelegate.mainBikeModel
    let location = AppDelegate.locationManager
    var map:MKMapView!

    private var initialPinsSet:Bool = false
    public var pendingUpdates:Bool = false
    
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
        //map.register(MKPinAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Annotation")
        map.showsUserLocation = true
        
        //liwten for updates on the other viewController
        let notificationName = Notification.Name(rawValue: Constants.identifiers.mapNotification)
        NotificationCenter.default.addObserver(self, selector: #selector(setUpdatesReady), name: notificationName, object: nil)
        
        addPins()
        // Do any additional setup after loading the view.
    }
    
    @objc func setUpdatesReady(){
        print("setUpdatesready in map")
        pendingUpdates = true
    }
    
    func addPins(){
        
        guard model.locations.count > 0 else {
            return
        }
        
        for station in model.locations{
            
            var mainStationObject:NYCBikeStationInfo?
            
            for savedStation in model.stationData!{
                
                if savedStation.external_id == station.key{
                    mainStationObject = savedStation
                    break
                }
                
            }
            
            let point = MKMapPoint(station.value.coordinate)

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
         initialPinsSet = true
        
    }
    
    func updatePins(){
        
        if(pendingUpdates){
        
            for pin in pins{
                
                //TODO: update pins with new info
                
                pin.subtitle = "updated"
                
            }
            pendingUpdates = false
        }
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
        
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
        
        if(!initialPinsSet){
            addPins()
        } else {
            updatePins()
        }
    
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
        //addPins()
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
