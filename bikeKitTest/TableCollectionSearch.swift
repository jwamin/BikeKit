import UIKit
import BikeKit


extension TableViewController : UISearchControllerDelegate{
    
    func willDismissSearchController(_ searchController: UISearchController) {
        self.refresh()
    }
    
}

extension TableViewController : UISearchResultsUpdating{
    
    
    func updateSearchResults(for searchController: UISearchController) {
        
        let searchString = searchController.searchBar.text!.lowercased()
        print(searchString)
        let resultsController = (searchController.searchResultsController as! SearchTableViewController)
        
        let filtered = model.stationData!.filter {
            $0.name.lowercased().contains(searchString)
        }
        
        resultsController.setStationInfoSubset(newSet: filtered)
        
        
    }
    
    
}

class SearchTableViewController : UITableViewController {
    
    private var stationInfoSubset = [NYCBikeStationInfo]()
    private var favourites = UserDefaults.standard.array(forKey: "favourites") as? [String] ?? []
    
    
    func setStationInfoSubset(newSet:[NYCBikeStationInfo]){
        stationInfoSubset = newSet
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        tableView.register(Cell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stationInfoSubset.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Cell
        let data = stationInfoSubset[indexPath.row]
        cell.textLabel!.text = data.name
        
        if(favourites.contains(data.station_id)){
            cell.accessoryType = .checkmark
        }
        
        
        cell.detailTextLabel?.text = data.statusString()
        
        return cell
        
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
