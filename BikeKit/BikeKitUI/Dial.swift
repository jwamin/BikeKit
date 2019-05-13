//
//  Dial.swift
//  BikeKitUI
//
//  Created by Joss Manger on 5/13/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit


public class DialView : UIView{
    
    public let label = UILabel()
    var dialConstraints = [NSLayoutConstraint]()
    
    init() {
        super.init(frame: .zero)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = String(0)
        label.center = self.center
        
    }
    
    public override func layoutMarginsDidChange() {
        print("layout changed")
        label.sizeToFit()
        label.frame = self.frame
        label.center = self.center
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
   public override func updateConstraints() {
        super.updateConstraints()
        if(dialConstraints.count == 0){
            
            let constraints = [
            label.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1.0),
            label.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0)
            ]
            
            for (index, cons) in constraints.enumerated(){
                cons.identifier = "dial constraint \(index)"
            }
            
            NSLayoutConstraint.activate(constraints)
            dialConstraints = constraints
            
        }
        
        self.layoutIfNeeded()
    }
    
}
