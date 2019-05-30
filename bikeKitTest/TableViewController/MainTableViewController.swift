import UIKit
import BikeKit
import BikeKitUI


//Test UI View

class MainTableViewController : UITableViewController, DockSwitchProtocol {
    
    var prefetchData:[String]?
    
    
    let model = AppDelegate.mainBikeModel
    let mapNotification = Notification(name: Notification.Name.init(rawValue: Constants.identifiers.mapNotification))
    
    var refreshed:UIRefreshControl!
    
    let locator = Locator()
    
    var toastDelegate:ToastDelegate?
    
    var dockSwitch:SharedSwitch!
    var dockLabel:UILabel!
    var dockStatus:NYCBikeStationCapacityQuery = .bikes
    
    var updates = [IndexPath]()
    
    //let editButtonItem:UIBarButtonItem!
    var doneButtonItem:UIBarButtonItem!
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        
        //initial controller setup
        self.title = Constants.strings.favouritesTitle
        self.definesPresentationContext = true
        
        //register cells
        tableView.register(DetailBikeKitViewCell.self, forCellReuseIdentifier: Constants.identifiers.detailCellIdentifier)
        model.delegate = self
        
        //Refresh Control
        refreshed = UIRefreshControl(frame: .zero)
        refreshed.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshed
        tableView.estimatedRowHeight = 85.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.prefetchDataSource = self
        
        //Reordering of table view
        self.editButtonItem.action = #selector(beginEditing)
        doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(beginEditing))
        self.navigationItem.rightBarButtonItem = editButtonItem
        
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
        
        
        //Basic Searching
        let searchTable = SearchTableViewController()
        searchTable.restorationIdentifier = Constants.identifiers.searchRestoration
        searchTable.delegate = self
        let searchController = UISearchController(searchResultsController: searchTable)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = Constants.strings.searchingPlaceholder
        self.navigationItem.searchController = searchController
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let favourites = model.favourites else {
            return
        }
        
        if(favourites.count>0){
            model.refreshFavourites()
        }
        
    }
    
    //MARK: UI Actions
    
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
            NotificationCenter.default.post(mapNotification)
        }
        
        //model.refreshFavourites()
    }
    
    
    
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
        
        self.distancesUpdated(nearestStations: model.getNearestStations())
    }
    
    //MARK: Table View Datasource and delegate methods
    
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
        
        //refresh of favourites here
        model.refreshFavourites()
        
        print("moved row \(sourceIndexPath.row) to \(destinationIndexPath.row), \(success)")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //MARK: TableViewDataSource
    
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
        
        let configured = cell.configureCell(indexPath: indexPath, with: data, query:dockStatus)
        
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
                    cell.setCellImage(image: img)
                }
                
            }
            
        } else {
            
            cell.setCellImage(image: model.images[data.external_id]!)
            
        }
        DispatchQueue.main.async {
            self.updateDistanceForCell(at: indexPath)
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
                model.refreshFavourites()
                NotificationCenter.default.post(mapNotification)
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
    
    //Delegate updates for Bike Model Data updates
    
    func uiUpdatesAreReady() {
        
        guard let _ = model.favourites else {
            return
        }
        
        DispatchQueue.main.async {
            //fix refresh flicker? (caused by reloadData + endRefreshing)
            CATransaction.begin()
            CATransaction.setAnimationDuration(1.0)
            CATransaction.setCompletionBlock({
                self.tableView.reloadData()
            })
            self.refreshed.endRefreshing()
            CATransaction.commit()

        }
        
    }
    
    //Networking failed, so show retry dialog
    func error(str: String?) {
        
        let errorView = UIAlertController(title: "Network Error", message: str, preferredStyle: .alert)
        let action = UIAlertAction(title: "Retry", style: .default) { (action) in
            self.model.restartAfterError()
        }
        errorView.addAction(action)
        self.present(errorView, animated: true, completion: nil)
        
    }
    
    
    func inCooldown(str:String?) {
        refreshed.endRefreshing()
        model.refreshFavourites()
        if let message = str {
            toastDelegate?.flyToast(str: message)
        }
        
    }
    
    func statusUpdatesAreReady(){
        print("status")
        model.refreshFavourites()
        model.updateLocation(userLocation: nil)
        
        NotificationCenter.default.post(mapNotification)
        
    }
    
   
    
    //Notification that nearest sites are available
    func distancesUpdated(nearestStations: [Nearest]) {
        
        if(nearestStations.count == 0){
            return
        }
        
        guard let visibleCellIndexPaths = self.tableView.indexPathsForVisibleRows else {
            return
        }
        
        DispatchQueue.global().async {
            
            NotificationCenter.default.post(name: Notification.Name.init(rawValue: "location"), object: nil)
            
            for visible in visibleCellIndexPaths{
                self.updateDistanceForCell(at: visible)
            }
            
        }
        
    }
    
     //MARK: Async tablecell updates
    // for each visible index path, check if it matches a station in the model.favourites
    func updateDistanceForCell(at indexPath:IndexPath){
        
         let nearestStations = model.getNearestStations()
        
        guard let favourites = self.model.favourites, nearestStations.count > 0, favourites.indices.contains(indexPath.row) else {
            return
        }
        
        let favourite = favourites[indexPath.row]
       
        
        guard let matchedStation:Nearest = nearestStations.first(where: { (nearest) -> Bool in
            nearest.externalID == favourite.external_id
        }) else {
            DispatchQueue.main.async {
                //if it doesnt, reset the info label to basic info
                self.updateCellWithDistance(indexPath: indexPath, data: favourite, distanceString: nil)
            }
            return
        }
        
        DispatchQueue.main.async {
            //if we get a match, update the cell with the processed info
            self.updateCellWithDistance(indexPath: indexPath, data: favourite, distanceString: matchedStation.distanceString)
        }
        
    }
    
    //call method on cell to update itself, if it is present
    func updateCellWithDistance(indexPath:IndexPath,data:NYCBikeStationInfo,distanceString:String?){
        
        guard let cell = self.tableView.cellForRow(at: indexPath) as? DetailBikeKitViewCell else {
            return
        }
        
        cell.updateDistance(data: data, distanceString: distanceString,query: dockStatus)
        
    }

    
}


extension MainTableViewController : UITableViewDataSourcePrefetching{
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        //test
        let defaults = model.userDefaults
        let favouritesArray = defaults.array(forKey: NYCBikeConstants.favouritesUserDefaultsKey) as? [String] ?? []
        
        for value in favouritesArray{
            prefetchData?.append(value)
        }
        
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        
    }
    
}
