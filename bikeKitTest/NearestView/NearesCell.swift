//
//  NearesCell.swift
//  BikeKitTest
//
//  Created by Joss Manger on 5/28/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit

class MyCell : UICollectionViewCell{
    
    
    @IBOutlet weak var label: UILabel!
    
    var text:String = ""{
        didSet{
            label.text = text
            label.sizeToFit()
        }
    }
    
    
    //    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    //
    //        label.sizeToFit()
    //        setNeedsLayout()
    //
    //        layoutIfNeeded()
    //
    //        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
    //        var frame = layoutAttributes.frame
    //        frame.size.height = ceil(size.height)
    //        frame.size.width = 150.0
    //        layoutAttributes.frame = frame
    //        return layoutAttributes
    //
    //    }
    
    
}
