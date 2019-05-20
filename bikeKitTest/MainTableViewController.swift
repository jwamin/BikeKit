import UIKit
import BikeKit
import BikeKitUI


//Test UI View

class MainTableViewController : UITableViewController {
    
    let model = AppDelegate.mainBikeModel
    var refreshed:UIRefreshControl!
    
    let locator = Locator()
    
    var toastDelegate:ToastDelegate?
    
    //let editButtonItem:UIBarButtonItem!
    var doneButtonItem:UIBarButtonItem!
    
    override func viewDidLoad() {
        
        self.title = Constants.strings.favouritesTitle
        self.definesPresentationContext = true
        
        tableView.register(DetailBikeKitViewCell.self, forCellReuseIdentifier: Constants.identifiers.detailCellIdentifier)
        model.delegate = self
        
        //Refresh Control
        refreshed = UIRefreshControl(frame: .zero)
        refreshed.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshed
        tableView.estimatedRowHeight = 85.0
        tableView.rowHeight = UITableView.automaticDimension
        
        //Reordering of table view
        self.editButtonItem.action = #selector(beginEditing)
        doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(beginEditing))
        
        self.navigationItem.rightBarButtonItem = editButtonItem
        
        //Basic Searching
        let searchTable = SearchTableViewController()
        searchTable.restorationIdentifier = Constants.identifiers.searchRestoration
        let searchController = UISearchController(searchResultsController: searchTable)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = Constants.strings.searchingPlaceholder
        self.navigationItem.searchController = searchController
        
        
    }
    
    @objc func refresh(){
        refreshed.beginRefreshing()
        model.refresh()
    }
    
    @objc func beginEditing(){
        if(!tableView.isEditing){
            tableView.setEditing(true, animated: true)
            self.navigationItem.rightBarButtonItem = doneButtonItem
        } else {
            tableView.setEditing(false, animated: true)
            self.navigationItem.rightBarButtonItem = editButtonItem
        }
        
        
    }
    
    //Table View Datasource and delegate methods
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        guard let favs = model.favourites else {
            return
        }
        print(sourceIndexPath,destinationIndexPath)
        let fav = favs[sourceIndexPath.row]
        
        let success = model.updateFavouriteToRow(id: fav.station_id, newRowIndex: destinationIndexPath.row)
        
        print("moved row \(sourceIndexPath.row) to \(destinationIndexPath.row), \(success)")
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let favorites = model.favourites else {
            return 0
        }
        
        return favorites.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let favorites = model.favourites, let cell = tableView.dequeueReusableCell(withIdentifier: Constants.identifiers.detailCellIdentifier) as? DetailBikeKitViewCell else {
            fatalError("errorrr")
        }
        
        let data = favorites[indexPath.row]
        
        let configured = cell.configureCell(indexPath: indexPath, with: data)
        
        return configured
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! DetailBikeKitViewCell
        
        //load map image
        
        let data = model.favourites![indexPath.row]
        
        if(model.images[data.external_id] == nil){
            
            cell.screenshotHandler = Locator.snapshotterForLocation(size: nil, location: model.locations[data.external_id]!,data) { [weak cell] (img) -> Void in
                
                self.model.images[data.external_id] = img
                
                if let cell = cell {
                    cell.mapView.image = img
                    cell.mapView.contentMode = .scaleAspectFill
                    cell.mapView.layer.borderColor = nil
                    cell.mapView.layer.borderWidth = 0
                }
                
            }
            
        } else {
            
            cell.mapView.image = model.images[data.external_id]
            cell.mapView.contentMode = .scaleAspectFill
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            guard let favourites = model.favourites  else {
                return
            }
            let favouriteToBeDeleted = favourites[indexPath.row]
            if(!model.toggleFavouriteForId(id: favouriteToBeDeleted.station_id)){
                model.favourites?.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
        default:
            break
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tabBarController?.selectedIndex = 1
        let navigationSibling = self.tabBarController?.viewControllers![1] as! UINavigationController
        let mapController = navigationSibling.topViewController as! MapViewController
        tableView.deselectRow(at: indexPath, animated: true)
        
        let station = model.favourites![indexPath.row]
        
        mapController.zoomToStation(station: station)
        
    }
    
    
}

extension MainTableViewController : NYCBikeUIDelegate {
    
    func updated() {
        
        guard let _ = model.favourites else {
            return
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshed.endRefreshing()
        }
        
        
    }
    
    func inCooldown(str:String?) {
        refreshed.endRefreshing()
        if let message = str {
            toastDelegate?.flyToast(str: message)
        }
        
    }
    
    func distancesUpdated(nearestStations: [Nearest]) {
        
        
        
        
        guard let favourites = self.model.favourites, let visibleCellIndexPaths = self.tableView.indexPathsForVisibleRows else {
            return
        }
        
        DispatchQueue.global().async {
            
                for visible in visibleCellIndexPaths{
                    
                    if !favourites.indices.contains(visible.row){
                        continue
                    }
                    
                    let favourite = favourites[visible.row]
                    
                    guard let matchedStation:Nearest = nearestStations.first(where: { (nearest) -> Bool in
                        nearest.externalID == favourite.external_id
                    }) else {
                        DispatchQueue.main.async {
                            let cell = self.tableView.cellForRow(at: visible) as! DetailBikeKitViewCell
                            cell.updateDistance(data: favourite, distanceString: nil)
                        }
                        continue
                    }
                    
                    
                    DispatchQueue.main.async {
                        let cell = self.tableView.cellForRow(at: visible) as! DetailBikeKitViewCell
                        cell.updateDistance(data: favourite, distanceString: matchedStation.distanceString)
                    }
                    
                    
                    
                }
            
        }
    }
    
}
