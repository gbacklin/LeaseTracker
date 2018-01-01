//
//  SummaryTableViewController.swift
//  LeaseTracker
//
//  Created by Gene Backlin on 5/9/16.
//  Copyright © 2016 Gene Backlin. All rights reserved.
//

import UIKit

class SummaryTableViewController: UITableViewController {

    var data: NSMutableDictionary?
    var dates: [String]?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tabBarController?.navigationItem.title = "Summary"

        self.data = PropertyList.read("LeaseData")?.mutableCopy() as? NSMutableDictionary
        self.dates = [String]()
        
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tableView.reloadData()
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
        if self.data != nil {
            let keys = self.data?.allKeys as! [String]
            let sortedKeys = keys.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedDescending }
            
            for key in sortedKeys {
                if key != "start" && key != "current" {
                    if self.dates?.contains(key) == false {
                        self.dates?.append(key)
                    }
                }
            }
            return (self.dates?.count)!
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        if self.data != nil {
            let key = self.dates![indexPath.row]
            let dict = self.data?.object(forKey: key)
            
            let currentDate: Date = ((dict! as AnyObject).object(forKey: "date") as? Date)!
            let miles =  (dict! as AnyObject).object(forKey: "miles") as? String
            
            cell.textLabel?.text = self.currentDate(currentDate)
            cell.detailTextLabel?.text = "\(miles!) miles"
        } else {
            cell.textLabel?.text = "No mileage has been entered."
            cell.detailTextLabel?.text = ""
        }

        // Configure the cell...

        return cell
    }
    
    func currentDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = DateFormatter.Style.medium
        
        return dateFormatter.string(from: date)
    }

}
