//
//  NYCLocatorMap.swift
//  BikeKitUI
//
//  Created by Joss Manger on 5/13/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import MapKit

public class Locator : NSObject{
    
    public static let defaultSize:CGSize = CGSize(width: 60, height: 35.5)
    
    public static func snapshotForLocation(size:CGSize?,location:CLLocation,callback:(@escaping (UIImage)->Void)){
        
        DispatchQueue.global().async {
        
        
        let options:MKMapSnapshotter.Options = MKMapSnapshotter.Options()
        options.mapType = .standard
        options.size = size ?? Locator.defaultSize
        options.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
        
        let scrssnshotter = MKMapSnapshotter(options: options)
        scrssnshotter.start { (snapshot, err) in
            
            guard let image = snapshot?.image else {
                return
            }
            DispatchQueue.main.async {
            callback(image)
            }
            
        }
        
        }
            
    }
    
    
    
}
