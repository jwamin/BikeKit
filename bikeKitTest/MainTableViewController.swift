import UIKit
import BikeKit
import BikeKitUI


//Test UI View

class MainTableViewController : UITableViewController, NYCBikeUIDelegate, UITableViewDataSourcePrefetching{

    let model = AppDelegate.mainBikeModel
    var refreshed:UIRefreshControl!
    
    let locator = Locator()
    
    var toastDelegate:ToastDelegate?
    
    //let editButtonItem:UIBarButtonItem!
    var doneButtonItem:UIBarButtonItem!
    
    override func viewDidLoad() {
        self.definesPresentationContext = true
        tableView.register(DetailBikeKitViewCell.self, forCellReuseIdentifier: "cell")
        model.delegate = self
        self.title = "Favourites"
        refreshed = UIRefreshControl(frame: .zero)
        refreshed.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshed
        tableView.estimatedRowHeight = 85.0
        tableView.rowHeight = UITableView.automaticDimension
        //search Init
        
        self.editButtonItem.action = #selector(beginEditing)
        doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(beginEditing))
        
        self.navigationItem.rightBarButtonItem = editButtonItem
        
        
        let searchTable = SearchTableViewController()
        searchTable.restorationIdentifier = "searchTable"
        let searchController = UISearchController(searchResultsController: searchTable)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search to add stations to favourites"
        self.navigationItem.searchController = searchController
        
        
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
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
    
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        guard let favs = model.favourites else {
            return
        }
        print(sourceIndexPath,destinationIndexPath)
        let fav = favs[sourceIndexPath.row]
        
        let success = model.updateFavouriteToRow(id: fav.station_id, newRowIndex: destinationIndexPath.row)
        
        print("moved row \(sourceIndexPath.row) to \(destinationIndexPath.row), \(success)")
        
    }
    
    @objc func refresh(){
        refreshed.beginRefreshing()
        model.refresh()
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! DetailBikeKitViewCell

        guard let favorites = model.favourites else {
            fatalError("errorrr")
        }
        
        let data = favorites[indexPath.row]

        let configured = cell.configureCell(indexPath: indexPath, with: data)
        
//        cell.detailTextLabel?.text = data.statusString()
//        cell.imageView?.image = UIImage(named: "Bike")

        return configured
    }
    
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! DetailBikeKitViewCell
        
        //load map image
            
            let data = model.favourites![indexPath.row]
        
        if(model.images[data.external_id] == nil){
        
            cell.screenshotHandler = Locator.snapshotterForLocation(size: nil, location: model.locations[data.external_id]!,data) { (img) -> Void in
                
                self.model.images[data.external_id] = img
                
                    if let cell = tableView.cellForRow(at: indexPath) as? DetailBikeKitViewCell {
                        cell.mapView.image = img
                        cell.mapView.contentMode = .scaleAspectFill
                        
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
    
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        print("prefetching \(indexPaths)")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        self.tabBarController?.selectedIndex = 1
        let navigationSibling = self.tabBarController?.viewControllers![1] as! UINavigationController
        let mapController = navigationSibling.topViewController as! MapViewController
        tableView.deselectRow(at: indexPath, animated: true)
        
        var station = model.favourites![indexPath.row]
        
        mapController.zoomToStation(station: station)
        
    }
    
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
    
}
