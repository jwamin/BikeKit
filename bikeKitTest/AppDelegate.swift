//
//  AppDelegate.swift
//  bikeKitTest
//
//  Created by Joss Manger on 5/7/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import UIKit
import BikeKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    static var mainBikeModel = NYCBikeNetworking()
    static var locationManager = CLLocationManager()
    static var sharedUserDefaults = UserDefaults.init(suiteName: "group.jossy.bikekitgroup")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:
        [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        NYCBikeNetworking.groupedUserDefaults = AppDelegate.sharedUserDefaults
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let mainToastView = ToastViewController()
        
        let tabViewController = UITabBarController(nibName: nil, bundle: nil)
        mainToastView.addChild(tabViewController)
        mainToastView.view.insertSubview(tabViewController.view, belowSubview: mainToastView.blurView)
        tabViewController.didMove(toParent: mainToastView)
         
        let table = TableViewController()
        table.toastDelegate = mainToastView
        let map = MapViewController()
        
        let primaryNavigation = UINavigationController(rootViewController: table)
        let secondaryNavigation = UINavigationController(rootViewController: map)
        
        table.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 0)
        map.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 1)
        map.tabBarItem.title = "Map"
        
        tabViewController.viewControllers = [primaryNavigation,secondaryNavigation]
        
        print(CLLocationManager.locationServicesEnabled())
        
        AppDelegate.locationManager.requestWhenInUseAuthorization()
        
        //dummy.view.backgroundColor = .red
        //dummy.title = "dummy"
        
        window?.rootViewController = mainToastView
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

