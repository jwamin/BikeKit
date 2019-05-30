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

let annotationString = "Annotation"

class MapViewController: UIViewController, MKMapViewDelegate {

    let model = AppDelegate.mainBikeModel
    let location = AppDelegate.locationManager
    var map:MKMapView!

    private var initialPinsSet:Bool = false
    public var pendingUpdates:Bool = false
    
    var zoomToLocation = false
    
    private var userInitialZoomSet:Bool = false
    
    var pins = [BKPinAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Map"
        map = MKMapView(frame: self.view.frame)
        map.autoresizingMask = [.flexibleWidth,.flexibleWidth]
        view.addSubview(map)
        
        map.delegate = self
        //map.register(BKPinAnnotationView.self, forAnnotationViewWithReuseIdentifier: annotationString)
        map.showsUserLocation = true
        
        //liwten for updates on the other viewController
        let notificationName = Notification.Name(rawValue: Constants.identifiers.mapNotification)
        NotificationCenter.default.addObserver(self, selector: #selector(setUpdatesReady), name: notificationName, object: nil)
        
        addPins()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        for annotation in map.selectedAnnotations{
             map.deselectAnnotation(annotation, animated: true)
        }
        
       
        
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
            
            let data = model.getStationDataForId(extId: station.key)
            
            let point = MKMapPoint(station.value.coordinate)

            let annotation = makePin(point: point, data: data)
            
            pins.append(annotation)
           
        }
        
         map.addAnnotations(pins)
         initialPinsSet = true
        
    }
    
    private func makePin(point:MKMapPoint,data:NYCBikeStationInfo)->BKPinAnnotation{
        
        let annotation = BKPinAnnotation()
        
        annotation.coordinate = point.coordinate
        
        annotation.title = data.name
        annotation.subtitle = data.statusString()
        annotation.id = data.external_id
        annotation.isFavourite = model.isFavourite(extID: data.external_id)
        
        return annotation
        
    }
    
    func updatePins(){
        
        if(pendingUpdates){
        print("updating pins")
            for pin in pins{
                
                //TODO: update pins with new info
                
                let data = model.getStationDataForId(extId: pin.id)
                
                let modelIsFavourite = model.isFavourite(extID: data.external_id)
                
                if (pin.isFavourite != modelIsFavourite){
                    print(data.name)
                    pin.isFavourite = modelIsFavourite
                    let annotation = annotationForId(extId: data.external_id)!
                    map.removeAnnotation(annotation)
                    map.addAnnotation(annotation)
                }

                pin.subtitle = data.statusString()
            }
            
            pendingUpdates = false
        }
    }
    
    func annotationForId(extId:String)->BKPinAnnotation?{
        
        return map.annotations.first(where: { (annotation) -> Bool in
            if let bkAnnotation = annotation as? BKPinAnnotation{
                return bkAnnotation.id == extId
            }
            return false
        }) as? BKPinAnnotation
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        print(view)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let annotation = annotation as? BKPinAnnotation else {
            return nil
        }
        
        let identifier = annotationString
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = BKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            if let pin = annotationView as? BKPinAnnotationView{
                pin.annotation = annotation
            }
        }
        
        guard let customPin = annotationView as? BKPinAnnotationView else {
            return nil
        }
        
        let favourite = annotation.isFavourite
        if(favourite){
            customPin.pinTintColor = .purple
            customPin.calloutButton.setTitle("remove", for: .normal)
        }
    
        customPin.calloutButton.sizeToFit()
        
        return customPin
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
}
