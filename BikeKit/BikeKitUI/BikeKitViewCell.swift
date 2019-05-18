//
//  BikeKitViewCell.swift
//  BikeKitUI
//
//  Created by Joss Manger on 5/13/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit
import BikeKit
import MapKit

public class BikeKitViewCell: UITableViewCell {

    private var cellConstraints = [NSLayoutConstraint]()
    public var localImg:UIImage?
    public var dataContainer:UIView!
    
    //retain reference to map shotter, so we can shut that shit down if we move out of view
    public var screenshotter:MKMapSnapshotter?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: "cell")

        self.textLabel?.textAlignment = .right
        self.detailTextLabel?.textAlignment = .right
    
        imageView?.contentMode = .scaleAspectFit
        

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.accessoryType = .none
        if let screenshotter = self.screenshotter{
            print("halting snapshotter")
            screenshotter.cancel()
            self.screenshotter = nil
        }
        imageView?.image = nil
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

