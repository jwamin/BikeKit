//
//  NearestViewController.swift
//  BikeKitTest
//
//  Created by Joss Manger on 5/26/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit
import BikeKit
import BikeKitUI

class NearestViewController: UIViewController, DockSwitchProtocol {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var textArea:UITextView?
    
    var initialSet = false
    var updating = false
    
    var datasource:[Nearest] = []
    
    var nearest:[Nearest] = []{
        willSet{
            print("updated")
            initialSet = true
        }
        didSet{
            
            if(!updating && initialSet){
                let indexPaths = calculateDifferences(old: oldValue, new: nearest)
                print(indexPaths)
//                 DispatchQueue.main.async {
//                self.datasource = self.nearest
//                self.collectionView.reloadData()
//                self.updating = false
//                }
                DispatchQueue.main.async {
                    self.performUpdates(inserted: indexPaths.inserted, deleted: indexPaths.deleted, moved: indexPaths.moved)
                }
            }
            
        }
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        nearest = []
        
        collectionView.register(UINib(nibName: "NearestCell", bundle: Bundle.main), forCellWithReuseIdentifier: "Cell")
        
        //Left bar button item
        dockSwitch = SharedSwitch()
        dockSwitch.setSharedId(newId: 1)
        dockSwitch.addTarget(self, action: #selector(dockSwitchUpdated(_:)), for: .valueChanged)
        dockLabel = UILabel()
        dockLabel.font = UIFont.preferredFont(forTextStyle: .body)
        dockLabel.text = "Bikes"
        
        let customView = UIStackView(arrangedSubviews: [dockSwitch,dockLabel])
        customView.spacing = 8
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customView)
        
        
        self.title = "Nearest Stations"
        
        // Do any additional setup after loading the view.
    }
    
    var dockSwitch:SharedSwitch!
    var dockLabel:UILabel!
    var dockStatus: NYCBikeStationCapacityQuery = .bikes
    
    @objc func dockSwitchUpdated(_ sender:Any){
        
        switch dockSwitch.isOn {
        case true:
            dockLabel.text = "Docks"
            dockStatus = .docks
        default:
            dockLabel.text = "Bikes"
            dockStatus = .bikes
        }

        dockSwitch.postNotification()
        
        update()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateNearest), name: Notification.Name.init(rawValue: "location"), object: nil)
        
        update()
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.init(rawValue: "location"), object: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension NearestViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! MyCell
        let index = indexPath.row
        let nearestInfo = datasource[index]
        let itemString = (dockStatus == .bikes) ? "bikes" : "docks"
        let unitNumber = (dockStatus == .bikes) ? nearestInfo.info.status!.num_bikes_available : nearestInfo.info.status!.num_docks_available
        cell.text = "\(index+1). \(nearestInfo.info.name)\n\(unitNumber) \(itemString) available -  \(nearestInfo.distanceString)\n\n"
        
        return cell
        
    }

    private func calculateDifferences(old:[Nearest],new:[Nearest])->(inserted:[IndexPath],deleted:[IndexPath],moved:[(from:IndexPath,to:IndexPath)]){
        
        var deleted = [IndexPath]()
        var inserted = [IndexPath]()
        var moved = [(IndexPath,IndexPath)]()
        
        for (oldIndex,oldElement) in old.enumerated(){
            
            if(!new.contains(where: { (newElement) -> Bool in
                newElement.info.external_id == oldElement.externalID
            })){
                //the new list does not contain something that is on the old list
                //so we add it to the delete array
                deleted.append(IndexPath(row: oldIndex, section: 0))
            }
            
        }
        
        for (newIndex,newElement) in new.enumerated(){
            
            if(!old.contains { (oldElement) -> Bool in
                oldElement.info.external_id == newElement.externalID
                }){
                //old does not contain new element
                //it is part of the INSERTED list
                inserted.append(IndexPath(row: newIndex, section: 0))
            } else {
                //old does contain new element
                for (oldIndex,oldElement) in old.enumerated(){
                    if(oldElement.externalID == newElement.externalID){
                        //if the index has changed, we need the old and new index to be added to the MOVED array
                        if(oldIndex != newIndex){
                            moved.append((IndexPath(row: oldIndex, section: 0), IndexPath(row: newIndex, section: 0)))
                        }
                    }
                }
                
            }
            
        }
        
        //we order the moved array in order of descending deletions, since we need to process deletes in descending order
        moved.sort { (first, second) -> Bool in
            return first.0.row>second.0.row
        }
        
        deleted.sort { (first, second) -> Bool in
            first.row>second.row
        }
        
        //Sorting Magic here
        
        return (inserted,deleted,moved)
        
    }
    
    @objc
    func updateNearest(){
        
        update()
        
    }
    
    func update(){
        nearest = NYCBikeModel.smartOrderingOfNearestStations(AppDelegate.mainBikeModel.getNearestStations(), query: dockStatus)
    }
    
    
    private func performUpdates(inserted:[IndexPath],deleted:[IndexPath],moved:[(from:IndexPath,to:IndexPath)]){
        updating = true
        
        if(inserted.count == 0 && deleted.count == 0 && moved.count == 0 && datasource.count > 0 && initialSet){
            UIView.performWithoutAnimation {
                datasource = nearest
                collectionView.reloadData()
                self.updating = false
            }
            return
        }
        
        let rawDeletes = deleted.map{
            $0.row
        }
        
        let moveDeletes = moved.map{
            $0.from.row
        }
        
        let smooshedDeletes = (rawDeletes + moveDeletes).sorted{
            $0>$1
        }
        
        let rawInserts = inserted.map{
            $0.row
        }
        
        let moveInserts = moved.map{
            $0.to.row
        }
        
        let smooshedInserts = (rawInserts + moveInserts)
        
        let smooshedSorted = smooshedInserts.sorted{
            $0<$1
        }
        
        print(smooshedDeletes)
        print(rawInserts,moveInserts)
        print(smooshedSorted)
        print(nearest.count)
        
        //        UIView.performWithoutAnimation {
        //            datasource = nearest
        //            collectionView.reloadData()
        //            self.updating = false
        //        }
        
        collectionView.performBatchUpdates({
            
            //get moved items
            //            var movedItems:[Int:Nearest] = [:]
            //
            //            for movedIndex in moveDeletes{
            //                movedItems[movedIndex] = datasource[movedIndex]
            //            }
            
            for delete in smooshedDeletes{
                
                datasource.remove(at: delete)
                
            }
            
            for insert in smooshedSorted{
                datasource.insert(nearest[insert], at: insert)
            }
            
            //Collection View Updates
            collectionView.deleteItems(at: deleted)
            collectionView.insertItems(at: inserted)
            
            for moved in moved{
                
                collectionView.moveItem(at: moved.from, to: moved.to)
                
            }
            
        }) { (complete) in
            print("complete")
            
            UIView.performWithoutAnimation{
                self.collectionView.reloadSections(IndexSet(integer: 0))
                self.updating = false
            }
            
            
        }
        
    }
    
    
}


extension NearestViewController {
    
    
    /// update the main text view with the nearest stations, or display fallback message
    @objc
    func printNearestToTextArea(){
        
        DispatchQueue.main.async {
            
            
            guard let textArea = self.textArea, AppDelegate.mainBikeModel.getNearestStations().count > 0 else {
                return
            }
            textArea.text = ""
            let nearestStations = AppDelegate.mainBikeModel.getNearestStations()
                for (index,nearest) in NYCBikeModel.smartOrderingOfNearestStations(nearestStations, query: .bikes).enumerated() {
                    switch self.dockStatus{
                        case .bikes:
                            textArea.text += "\(index+1). \(nearest.info.name)\n\(nearest.info.status!.num_bikes_available) \(self.dockStatus.rawValue) available -  \(nearest.distanceString)\n\n"
                        case .docks:
                            textArea.text += "\(index+1). \(nearest.info.name)\n\(nearest.info.status!.num_docks_available) \(self.dockStatus.rawValue) available -  \(nearest.distanceString)\n\n"
                    }
                    
                }
            
            if (textArea.text.count == 0){
                textArea.text = "Refresh on main screen to see nearest locations"
            }
            
        }
        
    }
    
    
}
