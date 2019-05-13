//
//  BikeKitViewCell.swift
//  BikeKitUI
//
//  Created by Joss Manger on 5/13/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit

public class BikeKitViewCell: UITableViewCell {

    
    public var localImg:UIImage?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: "cell")
        print("cell!")

        self.textLabel?.textAlignment = .right
        self.detailTextLabel?.textAlignment = .right
    
       //self.updateConstraints()
        

        imageView?.backgroundColor = .green

            //print(mainLabel,detailLabel,textLabel,detailTextLabel)
    }
    
//    public override func updateConstraints() {
//        super.updateConstraints()
//        if (cellConstraints.count == 0){
//            let safeArea = self.safeAreaLayoutGuide
//
//            var constraints:[NSLayoutConstraint] = [
//            mapView.leftAnchor.constraint(equalToSystemSpacingAfter: safeArea.leftAnchor, multiplier: 1.0),
//            mapView.topAnchor.constraint(equalToSystemSpacingBelow: safeArea.topAnchor, multiplier: 1.0),
//            mapView.heightAnchor.constraint(equalToConstant: 50),
//            safeArea.bottomAnchor.constraint(equalToSystemSpacingBelow: mapView.bottomAnchor, multiplier: 1.0),
//            mapView.widthAnchor.constraint(equalTo: mapView.heightAnchor, multiplier: 1.0)//,
////            self.textLabel!.leftAnchor.constraint(equalToSystemSpacingAfter: mapView.rightAnchor, multiplier: 1.0),
////            self.detailTextLabel!.leftAnchor.constraint(equalToSystemSpacingAfter: mapView.rightAnchor, multiplier: 1.0)
//            ]
//
//            cellConstraints = constraints
//
//            for constraint in cellConstraints{
//                constraint.identifier = "dodgy additional view constraint"
//            }
//
//            NSLayoutConstraint.activate(cellConstraints)
//
//        }
//    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.accessoryType = .none
        imageView?.backgroundColor = .green
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
