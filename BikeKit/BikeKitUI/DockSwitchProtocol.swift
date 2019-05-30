//
//  DockSwitchProtocol.swift
//  BikeKitTest
//
//  Created by Joss Manger on 5/28/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit
import BikeKit

public protocol DockSwitchProtocol {
    var dockSwitch:SharedSwitch! { get set }
    var dockLabel:UILabel! { get set }
    var dockStatus:NYCBikeStationCapacityQuery { get set }
    func dockSwitchUpdated(_ sender:Any)
}

public protocol SharedSwitchProtocol {
    var id:Int { get }
}

public struct SwitchData{
    public let id:Int
    public let state:Bool
    public let sender:SharedSwitch
}

public class SharedSwitch : UISwitch, SharedSwitchProtocol{
    
    public private(set) var id = 0
    
    public func setSharedId(newId:Int){
        self.id = newId
    }
    
    let notificationName = Notification.Name.init(rawValue: "switchUpdate")
    
    public init(){
        
        super.init(frame: .zero)
        NotificationCenter.default.addObserver(self, selector: #selector(updateFromNotification(_:)), name: notificationName, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func updateFromNotification(_ notification:Notification){
        
        guard let data = notification.object as? SwitchData else {
            return
        }
        print(data.sender.description)
        if(data.sender == self){
            return
        }
        
        if data.id == self.id{
            self.isOn = data.state
        }
    }
    
    
    public func postNotification(){
        
        let data = SwitchData(id: self.id, state: self.isOn,sender: self)
        NotificationCenter.default.post(name: notificationName, object: data)
    }
    
}

