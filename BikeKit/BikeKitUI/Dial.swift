//
//  Dial.swift
//  BikeKitUI
//
//  Created by Joss Manger on 5/13/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit

//#if targetEnvironment(simulator)

func degreesToRadians(degrees:CGFloat)->CGFloat{
    return degrees * (.pi/180)
}

//#else
//import jossy
//#endif


public class DialView : UIView{
    
    public let label = UILabel()
    var dialConstraints = [NSLayoutConstraint]()
    
    var total:Int = 0{
        didSet{
            self.setNeedsDisplay()
        }
    }
    var current:Int = 0{
        didSet{
            self.setNeedsDisplay()
        }
    }
    var anticlockwise:Bool = true
    
    let startAngle:CGFloat = degreesToRadians(degrees: 140)
    let endAngle:CGFloat = degreesToRadians(degrees: 400)
    let radius:CGFloat = 14
    let lineWidth:CGFloat = 7
    
    init() {
        super.init(frame: .zero)
        self.isOpaque = false
        self.clipsToBounds = false
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = String(0)
        label.center = self.center
        label.font = UIFont.preferredFont(forTextStyle: .body)
        
    }
    
    public override func layoutMarginsDidChange() {
        super.layoutMarginsDidChange()
        label.sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
       
        let context = UIGraphicsGetCurrentContext()
        //let drawrect = rect.insetBy(dx: -10, dy: -10)
        let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        
        let swing = endAngle - startAngle
        
        let fraction = CGFloat(current) / CGFloat(total)
        
        var finalEndAngle:CGFloat = 0
        
        if(!anticlockwise){
           finalEndAngle = endAngle - (swing * fraction)
        } else {
            finalEndAngle = startAngle + (swing * fraction)
        }
        
        context?.beginPath()
        context?.setLineCap(.round)
        context?.setLineWidth(lineWidth)
        context?.setFillColor(UIColor.white.cgColor)
        
        
        if(!anticlockwise){
            context?.setStrokeColor(UIColor.red.cgColor)
            context?.addArc(center: center, radius: radius, startAngle: endAngle, endAngle: finalEndAngle, clockwise: !anticlockwise)
        } else {
            context?.setStrokeColor(UIColor.green.cgColor)
            context?.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: finalEndAngle, clockwise: !anticlockwise)
        }
        
        context?.strokePath()
    
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        //invalidate drawing when
        super.traitCollectionDidChange(previousTraitCollection)
        self.setNeedsDisplay()
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
