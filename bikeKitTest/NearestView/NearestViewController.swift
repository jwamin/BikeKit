//
//  NearestViewController.swift
//  BikeKitTest
//
//  Created by Joss Manger on 5/26/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit
import BikeKit

class NearestViewController: UIViewController {
    @IBOutlet weak var textArea: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Nearest Stations"
        
        // Do any additional setup after loading the view.
    }


    override func awakeFromNib() {
        print("awake")
    }
    
    
    /// update the main text view with the nearest stations, or display fallback message
    @objc
    func printNearestToTextArea(){
        
        DispatchQueue.main.async {
    
        
            let textArea = self.textArea!
                textArea.text = ""
            
            if(AppDelegate.mainBikeModel.nearestStations.count>0){
                for (index,nearest) in NYCBikeModel.smartOrderingOfNearestStations(AppDelegate.mainBikeModel.nearestStations, query: .bikes).enumerated() {
                    textArea.text += "\(index+1). \(nearest.info.name)\n\(nearest.info.status!.num_bikes_available) bikes available -  \(nearest.distanceString)\n\n"
                }
            }
            
            if (textArea.text.count == 0){
                textArea.text = "Refresh on main screen to see nearest locations"
            }
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(printNearestToTextArea), name: Notification.Name.init(rawValue: "location"), object: nil)
        
        printNearestToTextArea()
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.init(rawValue: "location"), object: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
