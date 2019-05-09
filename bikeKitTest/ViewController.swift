import UIKit
import BikeKit


//Test UI View

class TableViewController : UITableViewController, NYCBikeNetworkingDelegate{
    
    let model = AppDelegate.mainBikeModel
    var refreshed:UIRefreshControl!
    
    var toastDelegate:ToastDelegate?
    
    override func viewDidLoad() {
        self.definesPresentationContext = true
        tableView.register(Cell.self, forCellReuseIdentifier: "cell")
        model.delegate = self
        model.getNYCBikeAPIData(task: .info)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Cell
        guard let favorites = model.favourites else {
            fatalError("errorrr")
        }
        let data = favorites[indexPath.row]
        cell.textLabel!.text = data.name
       cell.detailTextLabel?.text = data.statusString()
       
        return cell
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

class Cell : UITableViewCell{
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: "cell")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//let view = TableViewController()
//PlaygroundPage.current.liveView = view

