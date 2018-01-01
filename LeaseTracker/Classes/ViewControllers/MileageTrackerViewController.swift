//
//  MileageTrackerViewController.swift
//  LeaseTracker
//
//  Created by Gene Backlin on 6/6/16.
//  Copyright © 2016 Gene Backlin. All rights reserved.
//

import UIKit
import CoreLocation

class MileageTrackerViewController: UIViewController, CLLocationManagerDelegate {
    var manager: CLLocationManager?
    var startLocation:CLLocation!
    var lastLocation: CLLocation!
    var traveledDistance:Double = 0
    var isTracking: Bool!
    var mileage: [String : Double]?
    
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var fullDistanceLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tabBarController?.navigationItem.title = "Tracking"

        self.manager = CLLocationManager()
        self.manager!.delegate = self
        self.manager!.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            self.manager!.allowsBackgroundLocationUpdates = true
            self.manager!.startUpdatingLocation()
            self.isTracking = false
            self.fullDistanceLabel.textColor = UIColor(red: 255.0/255.0, green: 0.0, blue: 10.0/255.0, alpha: 1)
            //self.startTracking(self.startButton)
            self.mileage = self.readData("mileage")
            self.checkForSavedData()
            
            NotificationCenter.default.addObserver(self, selector: #selector(MileageTrackerViewController.appMovedToBackground(_:)), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
            
        } else {
            self.startButton.isEnabled = false
            self.stopButton.isEnabled = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Tracking
    
    @IBAction func stopTracking(_ sender: AnyObject) {
        self.isTracking = false
        self.fullDistanceLabel.textColor = UIColor(red: 255.0/255.0, green: 0.0, blue: 10.0/255.0, alpha: 1)
        self.savedData()
    }
    
    @IBAction func startTracking(_ sender: AnyObject) {
        self.isTracking = true
        self.fullDistanceLabel.textColor = UIColor(red: 0.0, green: 255.0/255.0, blue: 0.0, alpha: 1)
        self.checkForSavedData()
    }
    
    func checkForSavedData() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateString = dateFormatter.string(from: Date())
        
        if let date = self.mileage?[dateString] {
            self.traveledDistance = date
            let fullDistance = (traveledDistance/1000) * 0.62137
            self.fullDistanceLabel.text = "\(NSString(format: "%.2f miles", fullDistance))"
        }
    }
    
    func savedData() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateString = dateFormatter.string(from: Date())
        
        self.mileage![dateString] = self.traveledDistance
        
        self.writeData("mileage", data:self.mileage!)
    }
    
    // MARK: - PropertyList
    
    func writeData(_ name: String, data: [String : Double]) {
        let rootPath: NSString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let fname = "\(name).plist"
        let bundlePath: NSString = rootPath.appendingPathComponent(fname as String) as NSString
        let aData: Data = NSKeyedArchiver.archivedData(withRootObject: data)
        let success = (try? aData.write(to: URL(fileURLWithPath: bundlePath as String), options: [.atomic])) != nil
        let result = (success) ? "Yes" : "No"
        NSLog("saved: \(result)")
    }
    
    func readData(_ name: String) -> [String : Double]? {
        var result: [String : Double]?
        let rootPath: NSString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let fname = "\(name).plist"
        let bundlePath: NSString = rootPath.appendingPathComponent(fname as String) as NSString
        
        let aData: Data? = try? Data(contentsOf: URL(fileURLWithPath: bundlePath as String))
        if (aData != nil) {
            result = NSKeyedUnarchiver.unarchiveObject(with: aData!) as? [String : Double]
        } else {
            result = [String : Double]()
        }
        
        return result
    }
    
    // MARK: - NSNotification
    
    @objc func appMovedToBackground(_ notification: Notification) {
        self.savedData()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
            
        case .notDetermined:
            NSLog("NotDetermined")
            break
            
        case .restricted:
            NSLog("Restricted")
            break
            
        case .denied:
            NSLog("Denied")
            break
            
        case .authorizedAlways:
            NSLog("AuthorizedAlways")
            break
            
        case .authorizedWhenInUse:
            NSLog("AuthorizedWhenInUse")
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if startLocation == nil {
            startLocation = locations.first! as CLLocation
        } else {
            if self.isTracking == true {
                // 2.23693629 MPH
                // 3.6 KPH
                let speed: CLLocationSpeed = lastLocation.speed * 2.23693629
                //let distance = startLocation.distanceFromLocation(locations.last! as CLLocation)
                let lastDistance = lastLocation.distance(from: locations.last! as CLLocation)
                self.traveledDistance += lastDistance
                
                // Distance in meters: traveledDistance/1000
                // Distance in miles: meters * 0.62137
                let fullDistance = (traveledDistance/1000) * 0.62137
                //let straightDistance = (distance/1000) * 0.62137
                
                self.speedLabel.text = "\(NSString(format: "%.2f mph", speed))"
                self.fullDistanceLabel.text = "\(NSString(format: "%.2f miles", fullDistance))"
            }
        }
        lastLocation = locations.last! as CLLocation
    }
    
}
