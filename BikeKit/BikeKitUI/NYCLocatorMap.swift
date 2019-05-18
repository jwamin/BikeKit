//
//  NYCLocatorMap.swift
//  BikeKitUI
//
//  Created by Joss Manger on 5/13/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import MapKit
import BikeKit

public class Locator : NSObject{
    
    //public static let defaultSize:CGSize = CGSize(width: 60, height: 35.5)
    public static let squareSize:CGSize = CGSize(width: 60, height: 60)
    public static let smallSquareSize:CGSize = CGSize(width: 50, height: 50)
    
    //return screenshotter then call stop in prepare for reuse
    public static func snapshotterForLocation(size:CGSize?,location:CLLocation,_ data:NYCBikeStationInfo? = nil,callback:(@escaping (UIImage)->Void)) -> MKMapSnapshotter{
        
        let options:MKMapSnapshotter.Options = MKMapSnapshotter.Options()
        options.mapType = .mutedStandard
        options.size = Locator.squareSize
        options.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
        options.showsPointsOfInterest = true
        options.showsBuildings = false
            
        let scrssnshotter = MKMapSnapshotter(options: options)
        
        DispatchQueue.global().async {
        scrssnshotter.start { (snapshot, err) in
            
            
            //this is very cool, if using the standard initialiser, the image and drawing will appear pixellated
            UIGraphicsBeginImageContextWithOptions(options.size, true, UIScreen.main.scale)
            snapshot?.image.draw(in: CGRect(origin: .zero, size: options.size))
            
            //Color the dot
            UIColor.gray.setFill()
            
            if let data = data,let status = data.status{
                if(status.is_renting==1){
                    UIColor.blue.setFill()
                } else {
                    UIColor.red.setFill()
                }
            }
            
            let context = UIGraphicsGetCurrentContext()
            context?.beginPath()
            context?.addArc(center: CGPoint(x: options.size.width / 2, y: options.size.height / 2), radius: 5, startAngle: 0, endAngle: 2 * .pi, clockwise: false)
            context?.fillPath()
            
            guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
                return
            }
            
            UIGraphicsEndImageContext()
            
            DispatchQueue.main.async {
                callback(image)
            }
            
        }
            
        }
        return scrssnshotter
    }
    
    
    
}
