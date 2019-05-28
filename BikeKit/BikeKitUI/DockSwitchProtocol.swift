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
    var dockSwitch:UISwitch! { get set }
    var dockLabel:UILabel! { get set }
    var dockStatus:NYCBikeStationCapacityQuery { get set }
    func dockSwitchUpdated(_ sender:Any)
}
