//
//  TodayViewController.swift
//  BikeKitTodayWidget
//
//  Created by Joss Manger on 5/11/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit
import NotificationCenter
import BikeKit
import BikeKitUI

class TodayViewController: UIViewController, NCWidgetProviding, NYCBikeUIDelegate,UITableViewDelegate,UITableViewDataSource {

    
    
    var tableView:UITableView!
    
    let bikeShareModel = NYCBikeModel()
    var label:UILabel!
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        let expanded = activeDisplayMode == .expanded
        var size = maxSize
        if let cellIsPresent = tableView.visibleCells.first{
            size = cellIsPresent.bounds.size
        }
        preferredContentSize = expanded ? tableView.contentSize : size
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        
        //setup User defaults
        
        if let userDefaults = UserDefaults(suiteName: Constants.identifiers.sharedUserDefaultsSuite){
            bikeShareModel.setUserDefaultsSuite(suite: userDefaults)
        }
        
        tableView = UITableView(frame: self.view.bounds)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(DetailBikeKitViewCell.self, forCellReuseIdentifier: Constants.identifiers.detailCellIdentifier)
        view.addSubview(tableView)
        tableView.isHidden = true
        
        let safeArea = self.view.safeAreaLayoutGuide
        
        let constraints:[NSLayoutConstraint] = [
        tableView.leftAnchor.constraint(equalToSystemSpacingAfter: safeArea.leftAnchor, multiplier: 1.0),
        tableView.topAnchor.constraint(equalToSystemSpacingBelow: safeArea.topAnchor, multiplier: 1.0),
        self.view.trailingAnchor.constraint(equalToSystemSpacingAfter: tableView!.trailingAnchor, multiplier: 1.0),
        self.view.bottomAnchor.constraint(equalToSystemSpacingBelow: tableView!.bottomAnchor, multiplier: 1.0)
        ]
        NSLayoutConstraint.activate(constraints)
        
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
        bikeShareModel.delegate = self
        label = self.view.subviews[0] as? UILabel
        label.text = Constants.strings.loadingLabelText
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bikeShareModel.favourites?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.identifiers.detailCellIdentifier, for: indexPath) as! DetailBikeKitViewCell
        guard let favorites = bikeShareModel.favourites else {
            fatalError("errorrr")
        }
        let data = favorites[indexPath.row]
       
        let configured = cell.configureCell(indexPath: indexPath, with: data)
        
        return configured
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let cell = cell as! DetailBikeKitViewCell
        
        //load map image
        
        let data = bikeShareModel.favourites![indexPath.row]
        
        if(bikeShareModel.images[data.external_id] == nil){
            
            cell.screenshotHandler = Locator.snapshotterForLocation(size: nil, location: bikeShareModel.locations[data.external_id]!) { (img) -> Void in
                
                self.bikeShareModel.images[data.external_id] = img
                
                if let cell = tableView.cellForRow(at: indexPath) as? DetailBikeKitViewCell {
                    cell.mapView.image = img
                    cell.layer.borderWidth = 0
                }
                
            }
            
        } else {
            
            cell.mapView.image = bikeShareModel.images[data.external_id]
        }
        
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        print("widget perform update")
        bikeShareModel.refreshFavourites{ error in
            
            if let error = error{
                switch(error){
                case .throttled:
                    completionHandler(NCUpdateResult.noData)
                    return
                case .failed:
                    completionHandler(NCUpdateResult.failed)
                    return
                default:
                    break
                }
            }
            
            self.uiUpdatesAreReady()
            
            completionHandler(NCUpdateResult.newData)
            
        }
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        
    }
    
    func error(str: String?) {
        bikeShareModel.restartAfterError()
    }
    
    func uiUpdatesAreReady() {

        tableView.isHidden = false
        label.removeFromSuperview()
        tableView.reloadData()
        self.widgetActiveDisplayModeDidChange(self.extensionContext!.widgetActiveDisplayMode, withMaximumSize: tableView.contentSize)
        
    }
    
    func statusUpdatesAreReady() {
        tableView.reloadData()
    }
    
    func inCooldown(str: String?) {
        return
    }
    
    func distancesUpdated(nearestStations: [Nearest]) {
        return
    }
    
}
