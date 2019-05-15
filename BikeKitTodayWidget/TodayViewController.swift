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
    
    
    let bikeNetworking = NYCBikeModel()
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
        
        tableView = UITableView(frame: self.view.bounds)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(DetailBikeKitViewCell.self, forCellReuseIdentifier: "detailCell")
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
        
        
        let sharedUserDefaults = UserDefaults.init(suiteName: "group.jossy.bikekitgroup")
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
        NYCBikeModel.groupedUserDefaults = sharedUserDefaults
        //bikeNetworking.assembleDataForFavourites()
        bikeNetworking.delegate = self
        label = self.view.subviews[0] as? UILabel
        label.text = "loading..."
        //label.removeFromSuperview()
        // Do any additional setup after loading the view.
        print("hello world")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bikeNetworking.favourites?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailBikeKitViewCell
        guard let favorites = bikeNetworking.favourites else {
            fatalError("errorrr")
        }
        let data = favorites[indexPath.row]
       
        let configured = cell.configureCell(indexPath: indexPath, with: data)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let cell = cell as! DetailBikeKitViewCell
        
        //load map image
        
        let data = bikeNetworking.favourites![indexPath.row]
        
        if(bikeNetworking.images[data.external_id] == nil){
            
            Locator.snapshotForLocation(size: nil, location: bikeNetworking.locations[data.external_id]!) { (img) -> Void in
                
                self.bikeNetworking.images[data.external_id] = img
                
                if let cell = tableView.cellForRow(at: indexPath) as? DetailBikeKitViewCell {
                    cell.mapView.image = img
                }
                
            }
            
        } else {
            
            cell.mapView.image = bikeNetworking.images[data.external_id]
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
       // bikeNetworking.refresh()
    }
    
    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        coordinator.animate(alongsideTransition: { (context) in
//            print("animated")
//        }) { (context) in
//            print("context")
//        }
//    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        print("widget perform uodate")
        bikeNetworking.assembleDataForFavourites{ error in
            
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
            
            self.updated()
            
            completionHandler(NCUpdateResult.newData)
            
        }
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        
    }
    
    func updated() {
//        label.text = ""
//        var str = ""
//        for station  in bikeNetworking.favourites!{
//            str += station.name+": "+station.statusString()+"\n\n"
//        }
//        label.text = str
//        label.sizeToFit()
        tableView.isHidden = false
        label.removeFromSuperview()
        tableView.reloadData()
        self.widgetActiveDisplayModeDidChange(self.extensionContext!.widgetActiveDisplayMode, withMaximumSize: tableView.contentSize)
        
    }
    
    func inCooldown(str: String?) {
        return
    }
    
}
