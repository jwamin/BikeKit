//
//  SearchTableViewController.swift
//  BikeKitTest
//
//  Created by Joss Manger on 5/22/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit

protocol FavouritesUpdatesDelegate {
    func added()
    func removed()
}

extension MainTableViewController : UISearchControllerDelegate, FavouritesUpdatesDelegate{
    
    func added() {
        let ip = IndexPath(row: updates.count, section: 0)
        updates.append(ip)
    }
    
    func removed() {
        if(updates.count>0){ // this doesnt work, it cause a crash if removing from search view
            updates.remove(at: updates.endIndex-1)
        }
    }
    
    
    func willDismissSearchController(_ searchController: UISearchController) {
        
        // ok so here, work out the difference between arrays and insert the new favourites animated
        print(updates)
        model.refreshFavourites()
        
//        let startCount = tableView.numberOfRows(inSection: 0)
//
//        let indexPaths = updates.enumerated().map { (index,_) in
//            return IndexPath(row: index+startCount, section: 0)
//        }
        updates.removeAll()
//
//        if indexPaths.count > 0{
//        tableView.insertRows(at: indexPaths, with: .automatic)
//        } else {
            tableView.reloadData()
//        }
        
        NotificationCenter.default.post(mapNotification)
        
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        (searchController.searchResultsController as! SearchTableViewController).setStationInfoSubset(newSet: model.stationData!)
    }
    
}

extension MainTableViewController : UISearchResultsUpdating{
    
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let stationData = model.stationData,  let resultsController = (searchController.searchResultsController as? SearchTableViewController) else {
            return
        }
        
        let searchString = searchController.searchBar.text!.lowercased()
        
        let filtered = model.stationData!.filter {
            $0.name.lowercased().contains(searchString)
        }
        print(filtered.count)
        resultsController.setStationInfoSubset(newSet: (filtered.count>0) ? filtered : stationData)
        
        
    }
    
}
