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

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.pinTintColor = .red
    }
    
}
