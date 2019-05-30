//
//  BKPinAnnotationView.swift
//  BikeKitTest
//
//  Created by Joss Manger on 5/22/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import MapKit

class BKPinAnnotation : MKPointAnnotation {
    
    var id:String?
    var isFavourite:Bool?
    
    override init() {
        super.init()
    }
}

class BKPinAnnotationView: MKPinAnnotationView {

    let calloutButton:UIButton
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        
        calloutButton = UIButton(type: .system)
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        calloutButton.setTitle("Add To Fav", for: .normal)
        calloutButton.addTarget(self, action: #selector(addFavAction), for: .touchUpInside)
        
        self.leftCalloutAccessoryView = calloutButton
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        self.pinTintColor = .red
    }
    
    @objc
    func addFavAction(_ sender:UIButton){
        guard let annotation = self.annotation as? BKPinAnnotation, let externalIdString = annotation.id else {
            return
        }
        
        DispatchQueue.global().async {
        let isFavourite = AppDelegate.mainBikeModel.toggleFavouriteWithExternalId(extId: externalIdString)
           DispatchQueue.main.async {
        (isFavourite) ? {
            sender.setTitle("remove", for: .normal)
            self.pinTintColor = .purple
            }() : {
                sender.setTitle("add Fav", for: .normal)
                self.pinTintColor = .red
        }()
        sender.sizeToFit()
        }
        }
    }
    
}
