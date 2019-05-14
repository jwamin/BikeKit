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
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        
    }
    
    public override func layoutMarginsDidChange() {
        super.layoutMarginsDidChange()
        label.sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
   public override func updateConstraints() {
    
        if(dialConstraints.count == 0){
            
//var constraints =             [
//            self.widthAnchor.constraint(equalToConstant: Locator.squareSize.height),
//            //self.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0),
//            label.centerXAnchor.constraint(equalToSystemSpacingAfter: self.centerXAnchor, multiplier: 1.0),
//            label.centerYAnchor.constraint(equalToSystemSpacingBelow: self.centerYAnchor, multiplier: 1.0)
//            ]
            
            var constraints = NSLayoutConstraint.constraints(withVisualFormat: "|-0-[label]-0-|", options: [], metrics: ["height":Locator.squareSize.height], views: ["label":label])
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[label]-0-|", options: [], metrics: ["height":Locator.squareSize.height], views: ["label":label])
            
            for (index, cons) in constraints.enumerated(){
                cons.identifier = "dial constraint \(index)"
            }
            
            NSLayoutConstraint.activate(constraints)
            dialConstraints = constraints
            self.layoutIfNeeded()
        }
        
    
    super.updateConstraints()
    }
    
}
