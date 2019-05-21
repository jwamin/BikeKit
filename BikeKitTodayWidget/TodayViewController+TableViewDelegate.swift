//
//  TodayViewController+TableViewDelegate.swift
//  BikeKitTodayWidget
//
//  Created by Joss Manger on 5/21/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit
import BikeKit
import BikeKitUI

extension TodayViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tableRows = bikeShareModel.favourites?.count {
            return (tableRows>maxRows) ? maxRows : tableRows // limit to 4
        }
        return 0
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
}
