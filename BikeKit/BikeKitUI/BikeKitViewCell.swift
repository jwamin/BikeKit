//
//  BikeKitViewCell.swift
//  BikeKitUI
//
//  Created by Joss Manger on 5/13/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit

public class BikeKitViewCell: UITableViewCell {

    private var cellConstraints = [NSLayoutConstraint]()
    public var localImg:UIImage?
    public var dataContainer:UIView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: "cell")
        print("cell!")

        self.textLabel?.textAlignment = .right
        self.detailTextLabel?.textAlignment = .right
    
        dataContainer = UIView()
        dataContainer.translatesAutoresizingMaskIntoConstraints = false
        dataContainer.backgroundColor = .red
        self.contentView.addSubview(dataContainer)
        
       self.updateConstraints()
        

        imageView?.backgroundColor = .green

            //print(mainLabel,detailLabel,textLabel,detailTextLabel)
    }
    
    public override func updateConstraints() {
        super.updateConstraints()
        if (cellConstraints.count == 0){
            let safeArea = self.safeAreaLayoutGuide

            var constraints:[NSLayoutConstraint] = [
            dataContainer.leftAnchor.constraint(equalToSystemSpacingAfter: safeArea.leftAnchor, multiplier: 1.0),
            dataContainer.topAnchor.constraint(equalToSystemSpacingBelow: self.imageView!.bottomAnchor, multiplier: 1.0),
            dataContainer.heightAnchor.constraint(equalToConstant: 50),
            safeArea.bottomAnchor.constraint(equalToSystemSpacingBelow: dataContainer.bottomAnchor, multiplier: 1.0)
            ]

            cellConstraints = constraints

            for constraint in cellConstraints{
                constraint.identifier = "dodgy additional view constraint"
            }

            NSLayoutConstraint.activate(cellConstraints)

        }
    }
    
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






public class DetailBikeKitViewCell: UITableViewCell {
    
    private var cellConstraints = [NSLayoutConstraint]()

    
    public var mapView:UIImageView!
    public var nameLabel:UILabel!
    public var distanceLabel:UILabel!
    
    public var dataContainer:UIStackView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "cell")
        print("cell!")
        
        self.textLabel?.textAlignment = .right
        self.detailTextLabel?.textAlignment = .right
        
        dataContainer = UIStackView()
        dataContainer.translatesAutoresizingMaskIntoConstraints = false
        dataContainer.axis = .horizontal
        dataContainer.spacing = 8
        dataContainer.alignment = .center
        dataContainer.distribution = .equalSpacing

        for color:UIColor in [.red,.green,.blue,.red]{
            let view = DialView()
            translatesAutoresizingMaskIntoConstraints = false
            
            view.widthAnchor.constraint(equalToConstant: 60.0).isActive = true
            
            
            view.backgroundColor = color
            dataContainer.addArrangedSubview(view)
            view.heightAnchor.constraint(equalTo: dataContainer.heightAnchor, multiplier: 1.0).isActive = true
        }
        
        
        
        self.contentView.addSubview(dataContainer)
        
        
        mapView = UIImageView(frame: CGRect(origin: .zero, size: Locator.defaultSize))
            mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.backgroundColor = .cyan
        self.contentView.addSubview(mapView)
        
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        
        distanceLabel = UILabel()
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(distanceLabel)
            
        self.updateConstraints()
        
        
        imageView?.backgroundColor = .green
        
        //print(mainLabel,detailLabel,textLabel,detailTextLabel)
    }
    
    public override func updateConstraints() {
        super.updateConstraints()
        if (cellConstraints.count == 0){
            let safeArea = self.contentView.safeAreaLayoutGuide
            
            mapView.setContentHuggingPriority(UILayoutPriority(999), for: .horizontal)
            mapView.setContentHuggingPriority(UILayoutPriority(999), for: .vertical)
            
            
            var constraints:[NSLayoutConstraint] = [
                mapView.topAnchor.constraint(equalToSystemSpacingBelow: safeArea.topAnchor, multiplier: 1.0),
                mapView.leadingAnchor.constraint(equalToSystemSpacingAfter: safeArea.leadingAnchor, multiplier: 1.0),
                //mapView.heightAnchor.constraint(equalToConstant: Locator.defaultSize.height),
                
                nameLabel.topAnchor.constraint(equalToSystemSpacingBelow: safeArea.topAnchor, multiplier: 1.0),
                nameLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: mapView.trailingAnchor, multiplier: 1.0),
                safeArea.trailingAnchor.constraint(equalToSystemSpacingAfter: nameLabel.trailingAnchor, multiplier: 1.0),
                
                distanceLabel.topAnchor.constraint(equalToSystemSpacingBelow: nameLabel.bottomAnchor, multiplier: 1.0),
                distanceLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: mapView.trailingAnchor, multiplier: 1.0),
                safeArea.trailingAnchor.constraint(equalToSystemSpacingAfter: distanceLabel.trailingAnchor, multiplier: 1.0),
                
                //dataContainer.heightAnchor.constraint(equalToConstant: 100),
                dataContainer.heightAnchor.constraint(equalToConstant: 60),
                dataContainer.leftAnchor.constraint(equalToSystemSpacingAfter: safeArea.leftAnchor, multiplier: 1.0),
                dataContainer.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: mapView.bottomAnchor, multiplier: 1.0),
                dataContainer.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: distanceLabel.bottomAnchor, multiplier: 1.0),
                safeArea.trailingAnchor.constraint(equalToSystemSpacingAfter: dataContainer.trailingAnchor, multiplier: 1.0),
                safeArea.bottomAnchor.constraint(equalToSystemSpacingBelow: dataContainer.bottomAnchor, multiplier: 1.0)
            ]
            
            cellConstraints = constraints
            
            for constraint in cellConstraints{
                constraint.identifier = "dodgy additional view constraint"
            }
            
            NSLayoutConstraint.activate(cellConstraints)
            distanceLabel.sizeToFit()
            
            self.layoutIfNeeded()
            
        }
    }
    
    public func getarrangedsubviews()->(DialView,DialView,DialView,DialView)?{
        guard let stack = dataContainer else {
            return nil
        }
        return (stack.arrangedSubviews[0],stack.arrangedSubviews[1],stack.arrangedSubviews[2],stack.arrangedSubviews[3]) as! (DialView, DialView, DialView, DialView)
        
    }
    
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
