//
//  DetailCell.swift
//  BikeKitUI
//
//  Created by Joss Manger on 5/13/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit
import BikeKit
import MapKit

public class DetailBikeKitViewCell: UITableViewCell {
    
    private var cellConstraints = [NSLayoutConstraint]()
    
    public var screenshotHandler:MKMapSnapshotter?
    
    public var mapView:UIImageView!
    public var nameLabel:UILabel!
    public var distanceLabel:UILabel!
    
    public var topStackView:UIStackView!
    public var headingsContainer:UIStackView!
    public var dataContainer:UIStackView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "cell")
        
        self.textLabel?.textAlignment = .right
        self.detailTextLabel?.textAlignment = .right
        
        topStackView = UIStackView()
        topStackView.translatesAutoresizingMaskIntoConstraints = false
        topStackView.axis = .horizontal
        topStackView.spacing = 8
        topStackView.alignment = .leading
        topStackView.distribution = .fill
        
        headingsContainer = UIStackView()
        headingsContainer.translatesAutoresizingMaskIntoConstraints = false
        headingsContainer.axis = .vertical
        headingsContainer.spacing = 8
        headingsContainer.alignment = .leading
        headingsContainer.distribution = .equalCentering
        
        dataContainer = UIStackView()
        dataContainer.translatesAutoresizingMaskIntoConstraints = false
        dataContainer.axis = .horizontal
        dataContainer.spacing = 8
        dataContainer.alignment = .fill
        dataContainer.distribution = .fillEqually
        
        
        //get rid of this!
        for _:UIColor in [.red,.green,.blue,.red]{
            let view = DialView()
            translatesAutoresizingMaskIntoConstraints = false
            
            //view.widthAnchor.constraint(equalToConstant: 60.0).isActive = true
            
            
            //view.backgroundColor = color
            dataContainer.addArrangedSubview(view)
            //view.heightAnchor.constraint(equalTo: dataContainer.heightAnchor, multiplier: 1.0).isActive = true
        }
        
        
        
        
        
        
        mapView = UIImageView(frame: CGRect(origin: .zero, size: Locator.squareSize))
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        mapView.layer.borderColor = UIColor.black.cgColor
        mapView.layer.borderWidth = 1
        
        mapView.clipsToBounds = true
        mapView.contentMode = .scaleAspectFit
        //self.contentView.addSubview(mapView)
        
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        
        distanceLabel = UILabel()
        distanceLabel.numberOfLines = 0
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        
        headingsContainer.addArrangedSubview(nameLabel)
        headingsContainer.addArrangedSubview(distanceLabel)
        self.contentView.addSubview(headingsContainer)
        
        
        topStackView.addArrangedSubview(mapView)
        topStackView.addArrangedSubview(headingsContainer)
        
        self.contentView.addSubview(topStackView)
        self.contentView.addSubview(dataContainer)
        
        //self.updateConstraints()
        self.setNeedsUpdateConstraints()
        
        
        
        //print(mainLabel,detailLabel,textLabel,detailTextLabel)
    }
    
    public override func updateConstraints() {
        
        if (cellConstraints.count == 0){
            //let safeArea = self.contentView.safeAreaLayoutGuide
            
//            mapView.setContentHuggingPriority(UILayoutPriority(999), for: .horizontal)
//            mapView.setContentHuggingPriority(UILayoutPriority(999), for: .vertical)
//            mapView.setContentCompressionResistancePriority(UILayoutPriority(999), for: .horizontal)
//            mapView.setContentCompressionResistancePriority(UILayoutPriority(999), for: .vertical)
            
            guard let topStackView = topStackView, let dataContainer = dataContainer else {
                return
            }
            
            let breakingConstraint = mapView.heightAnchor.constraint(equalTo: mapView.widthAnchor)
            breakingConstraint.priority = UILayoutPriority(rawValue: 250)
            var constraints:[NSLayoutConstraint] = [
                mapView.widthAnchor.constraint(equalToConstant: Locator.squareSize.width),
                breakingConstraint
                ]
            
            let views:[String:Any] = ["topStackView":topStackView,"detailStackView":dataContainer]
            
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "|-[topStackView]-|", options: [], metrics: nil, views: views)
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "|-[detailStackView]-|", options: [], metrics: nil, views: views)
            constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-[topStackView(>=1@250)]-8@250-[detailStackView(>=1@250)]-|", options: [], metrics: nil, views: views)
            
//            var constraints:[NSLayoutConstraint] = [
//                mapView.topAnchor.constraint(equalToSystemSpacingBelow: safeArea.topAnchor, multiplier: 1.0),
//                mapView.leadingAnchor.constraint(equalToSystemSpacingAfter: safeArea.leadingAnchor, multiplier: 1.0),
//                mapView.widthAnchor.constraint(equalToConstant: Locator.squareSize.width),
//                mapView.heightAnchor.constraint(greaterThanOrEqualTo: mapView.widthAnchor),
//
//                nameLabel.topAnchor.constraint(equalToSystemSpacingBelow: safeArea.topAnchor, multiplier: 1.0),
//                nameLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: mapView.trailingAnchor, multiplier: 1.0),
//                safeArea.trailingAnchor.constraint(equalToSystemSpacingAfter: nameLabel.trailingAnchor, multiplier: 1.0),
//
//                distanceLabel.topAnchor.constraint(equalToSystemSpacingBelow: nameLabel.bottomAnchor, multiplier: 1.0),
//                distanceLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: mapView.trailingAnchor, multiplier: 1.0),
//                safeArea.trailingAnchor.constraint(equalToSystemSpacingAfter: distanceLabel.trailingAnchor, multiplier: 1.0),
//
//                //dataContainer.heightAnchor.constraint(equalToConstant: 100),
//                //dataContainer.heightAnchor.constraint(equalToConstant: 60),
//                dataContainer.leftAnchor.constraint(equalToSystemSpacingAfter: safeArea.leftAnchor, multiplier: 1.0),
//                dataContainer.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: mapView.bottomAnchor, multiplier: 1.0),
//                //dataContainer.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: distanceLabel.bottomAnchor, multiplier: 1.0),
//                safeArea.trailingAnchor.constraint(equalToSystemSpacingAfter: dataContainer.trailingAnchor, multiplier: 1.0),
//                safeArea.bottomAnchor.constraint(equalToSystemSpacingBelow: dataContainer.bottomAnchor, multiplier: 1.0)
//            ]
            
            cellConstraints = constraints
            
            for constraint in cellConstraints{
                constraint.identifier = "custom cell contstraints"
            }
            
            NSLayoutConstraint.activate(cellConstraints)
            distanceLabel.sizeToFit()
            
            self.layoutIfNeeded()
            
        }
        super.updateConstraints()
    }
    
    public func configureCell(indexPath:IndexPath, with data:NYCBikeStationInfo,query:NYCBikeStationCapacityQuery = .bikes) -> DetailBikeKitViewCell{
        let cell = self
        cell.nameLabel.text = data.name
        updateDistance(data: data, distanceString: nil,query: query)
        cell.distanceLabel.sizeToFit()
        
        
        
        if let (bikes,docks,electric,disabled) = cell.getarrangedsubviews(), let status = data.status {
            bikes.label.text = "\(status.num_bikes_available)\nBikes"
            bikes.total = data.capacity
            bikes.current = status.num_bikes_available
            //bikes.layoutMarginsDidChange()
            docks.label.text = "\(status.num_docks_available)\nDocks"
            docks.total = data.capacity
            docks.anticlockwise = false
            docks.current = status.num_docks_available
            //bikes.layoutMarginsDidChange()
            electric.label.text = "\(status.num_ebikes_available)\nElectric"
            electric.total = data.capacity
            electric.current = status.num_ebikes_available
            //bikes.layoutMarginsDidChange()
            disabled.label.text = "\(status.num_bikes_disabled)\nDisabled"
            disabled.anticlockwise = false
            disabled.total = data.capacity
            disabled.current = status.num_bikes_disabled
            //bikes.layoutMarginsDidChange()
        }
        
        
        cell.layoutIfNeeded()
        
        return self
        
    }
    
    public func setCellImage(image:UIImage){
        mapView.image = image
        mapView.contentMode = .scaleAspectFill
        mapView.layer.borderColor = nil
        mapView.layer.borderWidth = 0
    }
    
    public func updateDistance(data:NYCBikeStationInfo,distanceString:String?,query:NYCBikeStationCapacityQuery){
        if let distanceComputed = distanceString{
            
            let (str,status) = data.smartCapacityAssesmentString(type: query)
            let label = self.distanceLabel
            self.distanceLabel.text =  "\(data.capacity) docks - \(distanceComputed) \(str)"
            
            switch(status){
                case .empty:
                    label?.backgroundColor = .red
                case .good:
                    label?.backgroundColor = .cyan
                case .ok:
                    label?.backgroundColor = .green
                case .low:
                    label?.backgroundColor = .orange
                case .unknown:
                    label?.backgroundColor = .lightGray
            }
            label?.sizeToFit()
        } else {
            self.distanceLabel.text = "\(data.capacity) docks"
            self.distanceLabel.backgroundColor = .clear
        }
        
    }
    
    
    public func getarrangedsubviews()->(DialView,DialView,DialView,DialView)?{
        guard let stack = dataContainer else {
            return nil
        }
        return (stack.arrangedSubviews[0],stack.arrangedSubviews[1],stack.arrangedSubviews[2],stack.arrangedSubviews[3]) as? (DialView, DialView, DialView, DialView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        if(screenshotHandler != nil){
            screenshotHandler?.cancel()
            screenshotHandler = nil
        }
        
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

