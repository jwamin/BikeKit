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

class TodayViewController: UIViewController, NCWidgetProviding,NYCBikeNetworkingDelegate {
    

    
    
    
    let bikeNetworking = NYCBikeNetworking()
    var label:UILabel!
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        let expanded = activeDisplayMode == .expanded
        preferredContentSize = expanded ? label.intrinsicContentSize : maxSize
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        let sharedUserDefaults = UserDefaults.init(suiteName: "group.jossy.bikekitgroup")
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        NYCBikeNetworking.groupedUserDefaults = sharedUserDefaults
        //bikeNetworking.assembleDataForFavourites()
        bikeNetworking.delegate = self
        label = self.view.subviews[0] as? UILabel
        // Do any additional setup after loading the view.
        print("hello world")
    }
    
    override func viewDidAppear(_ animated: Bool) {
       // bikeNetworking.refresh()
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (context) in
            print("animated")
        }) { (context) in
            print("context")
        }
    }
    
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
        label.text = ""
        var str = ""
        for station  in bikeNetworking.favourites!{
            str += station.name+": "+station.statusString()+"\n\n"
        }
        label.text = str
        label.sizeToFit()
    }
    
    func inCooldown(str: String?) {
        return
    }
    
}
