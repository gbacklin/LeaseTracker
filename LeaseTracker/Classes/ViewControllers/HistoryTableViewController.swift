//
//  HistoryTableViewController.swift
//  Distance
//
//  Created by Gene Backlin on 4/3/16.
//  Copyright © 2016 Gene Backlin. All rights reserved.
//

import UIKit

class HistoryTableViewController: UITableViewController {
    var mileage: [String : Double]?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black;
        self.tableView.separatorColor = UIColor.lightGray
        
        self.tabBarController?.navigationItem.title = "History"

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.mileage = self.readData("mileage")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let keys = Array(self.mileage!.keys)
        return keys.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let keys = Array(self.mileage!.keys)
        let key = keys[indexPath.row]
    
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let date = dateFormatter.date(from: key)
        
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let dateString = dateFormatter.string(from: date!)

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = UIColor.clear

        // Configure the cell...
        cell.textLabel?.textColor = UIColor.lightGray
        cell.textLabel?.text = dateString

        return cell
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showHistory" {
            let controller: HistoryDetailViewController = segue.destination as! HistoryDetailViewController
            let indexPath: IndexPath = self.tableView.indexPathForSelectedRow!
            let keys = Array(self.mileage!.keys)
            let key = keys[indexPath.row]
            let miles = self.mileage![key]
            controller.date = key
            controller.miles = miles
        }
    }


    // In a storyboard-based application, you will often want to do a little preparation before navigation

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
}
