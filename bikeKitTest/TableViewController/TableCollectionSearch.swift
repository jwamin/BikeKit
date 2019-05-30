import UIKit
import BikeKit
import BikeKitUI
import MapKit


class SearchTableViewController : UITableViewController {
    
    private var stationInfoSubset = [NYCBikeStationInfo]()
    private var favourites = [String]()
    public var delegate:FavouritesUpdatesDelegate?
    
    var screenshotters = [IndexPath:MKMapSnapshotter](){
        didSet{
            if (screenshotters.count==0){
                print("no screenshotters left on stack!")
            } else if(screenshotters.count<3){
                screenshotters.forEach{
                    print("\($0.value.description) \($0.key.description)")
                }
                print("\n")
            } 
        }
    }
    
    func setStationInfoSubset(newSet:[NYCBikeStationInfo]){
        stationInfoSubset = newSet
        tableView.reloadData()
        
    }
    
    override func viewDidLoad() {
        tableView.register(BikeKitViewCell.self, forCellReuseIdentifier: Constants.identifiers.basicCellIdentifier)
        tableView.dataSource = self
        tableView.prefetchDataSource = self
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
        
        let model = AppDelegate.mainBikeModel
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.identifiers.basicCellIdentifier, for: indexPath) as! BikeKitViewCell
        let data = stationInfoSubset[indexPath.row]
        cell.textLabel!.text = data.name
        
        if(favourites.contains(data.station_id)){
            cell.accessoryType = .checkmark
        }
        
        let image:UIImage? = {
            return model.images[data.external_id]
        }()
        
        cell.imageView?.image = image ?? UIImage(named: Constants.identifiers.bikeImageName)
        cell.detailTextLabel?.text = "\(data.capacity ?? 0) docks in total."
        
        return cell
        
    }
    
        override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            
            let cell = cell as! BikeKitViewCell
    
            //load map image
            let model = AppDelegate.mainBikeModel
            let data = stationInfoSubset[indexPath.row]
            let imagePresent = model.images[data.external_id]
            
            if(imagePresent == nil){
    
                if(screenshotters[indexPath] == nil){
                    print("starting screenshotter for indexpath \(indexPath)")
                    startScreenShotterForIndexPath(indexPath: indexPath)
                } else {
                    print("there is already a screenshotter for \(indexPath)")
                }
                return
    
            } else {
                
                cell.imageView?.image = imagePresent
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
    
            }
        }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cancelScreenshotterForIndexPath(path: indexPath)
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



extension SearchTableViewController : UITableViewDataSourcePrefetching {
    
    func getData(for indexPath:IndexPath)->NYCBikeStationInfo?{
        
        if(stationInfoSubset.indices.contains(indexPath.row)){
            let data = stationInfoSubset[indexPath.row]
            return data
        }
        
        return nil
    }
    
    func startScreenShotterForIndexPath(indexPath:IndexPath){
        let model = AppDelegate.mainBikeModel
        if let data = getData(for: indexPath){
            
            if(model.images[data.external_id] != nil){
                print("skipping screenshotter for \(indexPath)")
                return
            }
            
            let locator = Locator.snapshotterForLocation(size: Locator.squareSize, location: model.locations[data.external_id]!) {  (img) -> Void in
                
                model.images[data.external_id] = img
                
                self.cancelScreenshotterForIndexPath(path: indexPath)
                
                if let cell = self.tableView.cellForRow(at: indexPath) as? BikeKitViewCell {
                    
                    cell.imageView?.image = img
                    
                    cell.setNeedsLayout()
                    cell.layoutIfNeeded()
                    
                }
                
            }
            
            screenshotters[indexPath] = locator
        }
    }
    
    func cancelScreenshotterForIndexPath(path:IndexPath){
        if let _ = getData(for: path){
            
            if let locator = screenshotters[path]{
                locator.cancel()
                screenshotters.removeValue(forKey: path)
            }
        }
    }
    
    //do image prefecthing here
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        print("prefetching for \(indexPaths)")
        
        indexPaths.forEach{
            startScreenShotterForIndexPath(indexPath: $0)
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        
        print("cancelling for \(indexPaths)")
        
        indexPaths.forEach{
            cancelScreenshotterForIndexPath(path: $0)
        }
    }
    
}
