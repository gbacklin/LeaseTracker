//
//  HistoryDetailViewController.swift
//  Distance
//
//  Created by Gene Backlin on 4/3/16.
//  Copyright © 2016 Gene Backlin. All rights reserved.
//

import UIKit

class HistoryDetailViewController: UIViewController {
    var date: String?
    var miles: Double?
    var mileage: [String : Double]?

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var milesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tabBarController?.navigationItem.title = "Details"
        
        self.updateDisplay()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh(){
        self.mileage = self.readData("mileage")
        self.miles = self.mileage![self.date!]
        
        self.updateDisplay()
    }
    
    func updateDisplay() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let date = dateFormatter.date(from: self.date!)
        
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let dateString = dateFormatter.string(from: date!)
        
        let fullDistance = (self.miles!/1000) * 0.62137
        
        self.dateLabel.text = dateString
        self.milesLabel.textColor = UIColor.lightGray
        self.milesLabel.text = "\(NSString(format: "%.2f miles", fullDistance))"

    }
    
    // MARK: - PropertyList
    
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

    @IBAction func back(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
}
