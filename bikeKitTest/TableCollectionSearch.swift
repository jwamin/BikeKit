import UIKit
import BikeKit
import BikeKitUI


extension TableViewController : UISearchControllerDelegate{
    
    func willDismissSearchController(_ searchController: UISearchController) {
        self.refresh()
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        searchController.searchResultsUpdater?.updateSearchResults(for: searchController)
    }
    
}

extension TableViewController : UISearchResultsUpdating{
    
    
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
    private var favourites = NYCBikeNetworking.groupedUserDefaults!.array(forKey: "favourites") as? [String] ?? []
    
    
    func setStationInfoSubset(newSet:[NYCBikeStationInfo]){
        stationInfoSubset = newSet
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        tableView.register(BikeKitViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stationInfoSubset.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BikeKitViewCell
        let data = stationInfoSubset[indexPath.row]
        cell.textLabel!.text = data.name
        
        if(favourites.contains(data.station_id)){
            cell.accessoryType = .checkmark
        }
        
        cell.imageView?.image = UIImage(named: "Bike")
        cell.detailTextLabel?.text = "\(data.capacity) docks in total."

        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! BikeKitViewCell
        
        //load map image
        
        let data = stationInfoSubset[indexPath.row]
        let model = AppDelegate.mainBikeModel
        if(model.images[data.external_id] == nil){
            
            Locator.snapshotForLocation(size: Locator.defaultSize, location: model.locations[data.external_id]!) { (img) -> Void in
                
                model.images[data.external_id] = img
                
                if let cell = tableView.cellForRow(at: indexPath) as? BikeKitViewCell {
                    cell.imageView?.image = img
                     cell.imageView?.contentMode = .scaleAspectFill
                }
                
            }
            
        } else {
            cell.imageView?.image = model.images[data.external_id]
        }
        
        cell.imageView?.contentMode = .scaleAspectFill
        
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
        
        cell.accessoryType = (AppDelegate.mainBikeModel.toggleFavouriteForId(id: id)) ? .checkmark : .none
        
        
        
    }
    
    
}
