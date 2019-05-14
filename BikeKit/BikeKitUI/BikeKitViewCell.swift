//
//  BikeKitViewCell.swift
//  BikeKitUI
//
//  Created by Joss Manger on 5/13/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit
import BikeKit

public class BikeKitViewCell: UITableViewCell {

    private var cellConstraints = [NSLayoutConstraint]()
    public var localImg:UIImage?
    public var dataContainer:UIView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: "cell")

        self.textLabel?.textAlignment = .right
        self.detailTextLabel?.textAlignment = .right
    
        imageView?.contentMode = .scaleAspectFill
        

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.accessoryType = .none
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

