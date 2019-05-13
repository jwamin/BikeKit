import UIKit
import BikeKit
import BikeKitUI


//Test UI View

class TableViewController : UITableViewController, NYCBikeNetworkingDelegate{
    
    let model = AppDelegate.mainBikeModel
    var refreshed:UIRefreshControl!
    
    let locator = Locator()
    
    var toastDelegate:ToastDelegate?
    
    override func viewDidLoad() {
        self.definesPresentationContext = true
        tableView.register(DetailBikeKitViewCell.self, forCellReuseIdentifier: "cell")
        model.delegate = self
        self.title = "Favourites"
        refreshed = UIRefreshControl(frame: .zero)
        refreshed.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshed
        
        //search Init
        
        let searchTable = SearchTableViewController()
        searchTable.restorationIdentifier = "searchTable"
        let searchController = UISearchController(searchResultsController: searchTable)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search to add stations to favourites"
        self.navigationItem.searchController = searchController
        
        
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
        
            Locator.snapshotForLocation(size: nil, location: model.locations[data.external_id]!) { (img) -> Void in
                
                self.model.images[data.external_id] = img
                
                    if let cell = tableView.cellForRow(at: indexPath) as? DetailBikeKitViewCell {
                        cell.mapView.image = img
                        cell.mapView.layer.contentsScale = UIScreen.main.scale
                    }
            
            }
            
        } else {
           
            cell.mapView.image = model.images[data.external_id]
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
    
    func updated() {
        
        guard let favs = model.favourites else {
            return
        }
        
        
        tableView.reloadData()
        refreshed.endRefreshing()

        
    }
    
    func inCooldown(str:String?) {
        refreshed.endRefreshing()
        if let message = str {
             toastDelegate?.flyToast(str: message)
        }
       
    }
    
}
