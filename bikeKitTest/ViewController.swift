import UIKit
import BikeKit


//Test UI View

class TableViewController : UITableViewController, NYCBikeNetworkingDelegate{
    
    let model = AppDelegate.mainBikeModel
    var refreshed:UIRefreshControl!
    
    override func viewDidLoad() {
        tableView.register(Cell.self, forCellReuseIdentifier: "cell")
        model.delegate = self
        model.getNYCBikeAPIData(task: .info)
        self.title = "Favourites"
        refreshed = UIRefreshControl(frame: .zero)
        refreshed.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshed
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
    
    func updated() {
        
        guard let favs = model.favourites else {
            return
        }
        
        
        tableView.reloadData()
        refreshed.endRefreshing()
        
        //        tableView.beginUpdates()
        //
        //        var ips = [IndexPath]()
        //
        //        for (index,fav) in favs.enumerated() {
        //            ips.append(IndexPath(item: index, section: 0))
        //        }
        //
        //        tableView.insertRows(at: ips, with: .automatic)
        //
        //        tableView.endUpdates()
        
        
    }
    
    func inCooldown() {
        refreshed.endRefreshing()
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

