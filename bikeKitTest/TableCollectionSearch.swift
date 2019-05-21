import UIKit
import BikeKit
import BikeKitUI

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
        if(updates.count>0){
            updates.remove(at: updates.endIndex-1)
        }
    }
    
    
    func willDismissSearchController(_ searchController: UISearchController) {
        
        // ok so here, work out the difference between arrays and insert the new favourites animated
        print(updates)
        
        
        let startCount = tableView.numberOfRows(inSection: 0)

        let indexPaths = updates.enumerated().map { (index,_) in
            return IndexPath(row: index+startCount, section: 0)
        }
        updates.removeAll()
        tableView.insertRows(at: indexPaths, with: .automatic)
        
        //self.refresh()
        
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        searchController.searchResultsUpdater?.updateSearchResults(for: searchController)
    }
    
}

extension MainTableViewController : UISearchResultsUpdating{
    
    
    func updateSearchResults(for searchController: UISearchController) {
        
       
        
        guard let stationData = model.stationData,  let resultsController = (searchController.searchResultsController as? SearchTableViewController) else {
            return
        }
        
        let searchString = searchController.searchBar.text!.lowercased()
        
        if searchString.count == 0{
            resultsController.setStationInfoSubset(newSet: stationData)
            return
        }
        
       
        
        let filtered = model.stationData!.filter {
            $0.name.lowercased().contains(searchString)
        }
        
        resultsController.setStationInfoSubset(newSet: filtered)
        
        
    }
    
}

class SearchTableViewController : UITableViewController {
    
    private var stationInfoSubset = [NYCBikeStationInfo]()
    private var favourites = [String]()
    public var delegate:FavouritesUpdatesDelegate?
    
    func setStationInfoSubset(newSet:[NYCBikeStationInfo]){
        stationInfoSubset = newSet
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        tableView.register(BikeKitViewCell.self, forCellReuseIdentifier: Constants.identifiers.basicCellIdentifier)
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let userDefaults = NYCBikeModel.groupedUserDefaults 
        
        favourites = userDefaults.array(forKey: "favourites") as? [String] ?? []
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stationInfoSubset.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.identifiers.basicCellIdentifier, for: indexPath) as! BikeKitViewCell
        let data = stationInfoSubset[indexPath.row]
        cell.textLabel!.text = data.name
        
        if(favourites.contains(data.station_id)){
            cell.accessoryType = .checkmark
        }
        
        cell.imageView?.image = UIImage(named: Constants.identifiers.bikeImageName)
        cell.imageView?.bounds.size = Locator.squareSize
        cell.detailTextLabel?.text = "\(data.capacity) docks in total."
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! BikeKitViewCell
        
        //load map image
        
        let data = stationInfoSubset[indexPath.row]
        let model = AppDelegate.mainBikeModel
        if(model.images[data.external_id] == nil){
            
            cell.screenshotter = Locator.snapshotterForLocation(size: Locator.squareSize, location: model.locations[data.external_id]!) { [weak cell] (img) -> Void in
                
                model.images[data.external_id] = img
                
                if let cell = cell {
                    
                    cell.imageView?.image = img
                    
                    cell.setNeedsLayout()
                    cell.layoutIfNeeded()
                }
                
            }
            
        } else {
            cell.imageView?.image = model.images[data.external_id]
            
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
          
        }
        
        
    
        
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.prepareForReuse()
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        
        let id = stationInfoSubset[indexPath.row].station_id
        
        let update = AppDelegate.mainBikeModel.toggleFavouriteForId(id: id)
        
        cell.accessoryType = (update) ? .checkmark : .none
        
        (update) ? delegate?.added() : delegate?.removed()
        
        
    }
    
    
}
