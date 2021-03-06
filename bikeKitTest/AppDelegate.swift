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
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    static var mainBikeModel = NYCBikeModel()
    static var locationManager = CLLocationManager()
    private var sharedUserDefaults:UserDefaults!
    private var location:CLLocationManager?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:
        [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        let locationManager = AppDelegate.locationManager
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.stopMonitoringSignificantLocationChanges()
        startAppropriateLocationManager(locationManager: locationManager, authorizationStatus: authorizationStatus)
        
        //setup user defaults
        sharedUserDefaults = UserDefaults.init(suiteName: Constants.identifiers.sharedUserDefaultsSuite)
        
        AppDelegate.mainBikeModel.setUserDefaultsSuite(suite: sharedUserDefaults)
        
        //Start Window
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let mainToastView = ToastViewController()
        
        let tabViewController = UITabBarController(nibName: nil, bundle: nil)
        mainToastView.addChild(tabViewController)
        mainToastView.view.insertSubview(tabViewController.view, belowSubview: mainToastView.blurView)
        tabViewController.didMove(toParent: mainToastView)
         
        let table = MainTableViewController()
        table.toastDelegate = mainToastView
        
        let nearest = NearestViewController(nibName: "NearestViewController", bundle: Bundle.main)
        nearest.loadViewIfNeeded()
        
        //Map view initialisation
        let map = MapViewController()
        map.loadViewIfNeeded()
        
        
        let primaryNavigation = UINavigationController(rootViewController: table)
        let secondaryNavigation = UINavigationController(rootViewController: map)
        let tertiaryNavigation = UINavigationController(rootViewController: nearest)
        
        //System Tabs for tab bar
        table.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 0)
        map.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 1)
        nearest.tabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 2)
        
        tabViewController.viewControllers = [primaryNavigation,secondaryNavigation,tertiaryNavigation]
        
        //AppDelegate.mainBikeModel.updateLocation(userLocation: locationManager.location)
        
        window?.rootViewController = mainToastView
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        print("resigning active")
        location?.stopUpdatingLocation()

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("backgrounded")

        location?.stopUpdatingLocation()
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("foregrounded")
        location?.startUpdatingLocation()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("became active")

        location?.startUpdatingLocation()
        
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
        print("about to terminate")

        
        location?.stopUpdatingLocation()
        
        
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func startAppropriateLocationManager(locationManager:CLLocationManager,authorizationStatus:CLAuthorizationStatus){
//        switch authorizationStatus {
//        case .authorizedAlways:
//            locationManager.pausesLocationUpdatesAutomatically = true
//            locationManager.startMonitoringSignificantLocationChanges()
//            location = locationManager
//        case .authorizedWhenInUse:
        if(authorizationStatus == .authorizedWhenInUse){
            print("starting location")
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.activityType = .otherNavigation
            locationManager.pausesLocationUpdatesAutomatically = true
            //locationManager.allowDeferredLocationUpdates(untilTraveled: CLLocationDistance(), timeout: <#T##TimeInterval#>)
            locationManager.startUpdatingLocation()
            location = locationManager
        }
//        default:
//            break
//        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            print("always")
        case .authorizedWhenInUse:
            print("when in use")
        case .denied:
            print("noooooo")
        default:
            print("something else \(status.rawValue)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("location update changed")
        
        guard let mostRecentLocation = locations.last else {
            return
        }
        
        AppDelegate.mainBikeModel.updateLocation(userLocation: mostRecentLocation)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    
}

