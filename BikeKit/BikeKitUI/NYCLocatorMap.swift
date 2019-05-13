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
    public static let squareSize:CGSize = CGSize(width: 60, height: 60)
    
    public static func snapshotForLocation(size:CGSize?,location:CLLocation,callback:(@escaping (UIImage)->Void)){
        
        DispatchQueue.global().async {
        
        
        let options:MKMapSnapshotter.Options = MKMapSnapshotter.Options()
        options.mapType = .standard
        options.size = Locator.squareSize
        options.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
        
        let scrssnshotter = MKMapSnapshotter(options: options)
        scrssnshotter.start { (snapshot, err) in
            
            UIGraphicsBeginImageContext(options.size)
            snapshot?.image.draw(at: .zero)
            UIColor.blue.setFill()
            let context = UIGraphicsGetCurrentContext()
            context?.beginPath()
            context?.addArc(center: CGPoint(x: options.size.width / 2, y: options.size.height / 2), radius: 5, startAngle: 0, endAngle: 2 * .pi, clockwise: false)
            context?.fillPath()
            
            guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
                return
            }
            DispatchQueue.main.async {
            callback(image)
            }
            
        }
        
        }
            
    }
    
    
    
}
