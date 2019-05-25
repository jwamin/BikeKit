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

let maxRows = 3

class TodayViewController: UIViewController, NCWidgetProviding, NYCBikeUIDelegate {

    var tableView:UITableView!
    
    let bikeShareModel = NYCBikeModel()
    var label:UILabel!
    
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
        tableView.leftAnchor.constraint(equalTo: safeArea.leftAnchor),
        tableView.topAnchor.constraint(equalTo: safeArea.topAnchor),
        safeArea.rightAnchor.constraint(equalTo: tableView.rightAnchor),
        safeArea.bottomAnchor.constraint(equalTo: tableView.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
        bikeShareModel.delegate = self
        label = self.view.subviews[0] as? UILabel
        label.text = Constants.strings.loadingLabelText
        
    }
    
    /// - Tag: ViewWillTransitionToSizeWithCoordinator
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let updatedVisibleCellCount = numberOfRowsToDisplay()
        let currentVisibleCellCount = self.tableView.visibleCells.count
        let cellCountDifference = updatedVisibleCellCount - currentVisibleCellCount
        print(updatedVisibleCellCount)
        // If the number of visible cells has changed, animate them in/out along with the resize animation.
        if cellCountDifference != 0 {
            coordinator.animate(alongsideTransition: { [unowned self] (UIViewControllerTransitionCoordinatorContext) in
                self.tableView.performBatchUpdates({ [unowned self] in
                    // Build an array of IndexPath objects representing the rows to be inserted or deleted.
                    let range = (1...abs(cellCountDifference))
                    let indexPaths = range.map({ (index) -> IndexPath in
                        return IndexPath(row: index, section: 0)
                    })
                    
                    // Animate the insertion or deletion of the rows.
                    if cellCountDifference > 0 {
                        self.tableView.insertRows(at: indexPaths, with: .fade)
                    } else {
                        self.tableView.deleteRows(at: indexPaths, with: .fade)
                    }
                    }, completion: nil)
                }, completion: nil)
        }
    }
    
//NCWidgetProviding
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        print("admchange", activeDisplayMode.rawValue)
        
        var size:CGSize = .zero
        switch activeDisplayMode {
        case .compact:
            size = maxSize
        case .expanded:
            guard (tableView.visibleCells.indices.contains(0) == true), let cell = tableView.visibleCells[0] as? DetailBikeKitViewCell else {
                return
            }
            let maxTableSize = cell.bounds.height * CGFloat(numberOfRowsToDisplay())
            size = CGSize(width: .zero, height: maxTableSize)
        default:
            break
        }
        let dtime:DispatchTime = DispatchTime.now() + 0.1
        DispatchQueue.main.asyncAfter(deadline: dtime) {
            self.preferredContentSize = size
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
    
    //BikeUIDelegate
    
    func error(str: String?) {
        bikeShareModel.restartAfterError()
    }
    
    func uiUpdatesAreReady() {
        bikeShareModel.refreshFavourites()
        
    }
    
    func statusUpdatesAreReady() {
        print("status refresh notified")
        DispatchQueue.main.async {
            
            self.tableView.isHidden = false
            self.label.removeFromSuperview()
            self.tableView.reloadData()
            
        }
    }
    
    func inCooldown(str: String?) {
        return
    }
    
    func distancesUpdated(nearestStations: [Nearest]) {
        return
    }
    
}
