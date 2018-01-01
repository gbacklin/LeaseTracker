//
//  EntryViewController.swift
//  LeaseTracker
//
//  Created by Gene Backlin on 5/8/16.
//  Copyright © 2016 Gene Backlin. All rights reserved.
//

import UIKit

let colorTop = UIColor(red: 192.0/255.0, green: 38.0/255.0, blue: 42.0/255.0, alpha: 1.0).cgColor
let colorBottom = UIColor(red: 35.0/255.0, green: 2.0/255.0, blue: 2.0/255.0, alpha: 1.0).cgColor

class EntryViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var mileageTextField: UITextField!
    @IBOutlet weak var currentDateTextField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var inputAccessoryToolBar: UIToolbar!
    @IBOutlet var mileageInputAccessoryToolBar: UIToolbar!

    @IBOutlet weak var actualMilesPerDayLabel: UILabel!
    @IBOutlet weak var actualTotalMilesLabel: UILabel!
    @IBOutlet weak var actualTotalDaysLabel: UILabel!
    @IBOutlet weak var projectedMilesPerDayLabel: UILabel!
    @IBOutlet weak var projectedTotalMilesLabel: UILabel!
    @IBOutlet weak var projectedTotalDaysLabel: UILabel!
    @IBOutlet weak var balanceDaysLabel: UILabel!
    @IBOutlet weak var milesDifferenceLabel: UILabel!
    
    var data: NSMutableDictionary?
    var selectedDate: Date?
    var gl: CAGradientLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.currentDateTextField.text = self.displayDate()
        let totalMiles = 15000.0*3.0
        let totalDays = 365.25 * 3.0
        let milesPerDay = totalMiles/totalDays

        self.projectedMilesPerDayLabel.text = NSString(format: "%.1f", milesPerDay) as String
        self.projectedTotalMilesLabel.text = NSString(format: "%.1f", totalMiles) as String
        self.projectedTotalDaysLabel.text = NSString(format: "%.1f", totalDays) as String
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tabBarController?.navigationItem.title = "Lease Tracker"
        
        self.mileageInputAccessoryToolBar.tintColor = UIColor.black
        self.mileageTextField.inputAccessoryView = self.mileageInputAccessoryToolBar

        self.data = PropertyList.read("LeaseData")?.mutableCopy() as? NSMutableDictionary
        if self.data == nil {
            self.getStartingMileage()
        } else {
            let startDict: NSDictionary = self.data?.object(forKey: "start") as! NSDictionary
            let startDate: Date = startDict.object(forKey: "date") as! Date
            let startMiles: Double = Double(startDict.object(forKey: "miles") as! String)!
            
            let currentDict: NSDictionary = self.data?.object(forKey: "current") as! NSDictionary
            let date: Date = currentDict.object(forKey: "date") as! Date
            let miles: Double = Double(currentDict.object(forKey: "miles") as! String)!
            
            let dateDifference: Int = self.daysBetweenDate(startDate, to: date)
            let milesDifference: Double = Double(miles) - startMiles
            
            if dateDifference > 0 {
                //let actualTotalMiles = milesDifference
                //let actualMilesPerDay = actualTotalMiles/Double(dateDifference)
                let actualTotalMiles = ((milesDifference/Double(dateDifference))*365.25)*3
                let actualMilesPerDay = milesDifference/Double(dateDifference)
                
                let projectedMilesPerDay: Double? = Double(self.projectedMilesPerDayLabel.text!)
                let projectedMiles: Double? = projectedMilesPerDay! * Double(dateDifference)
                let actualMilesDifference: Double? = milesDifference - projectedMiles!
                let actualMileageBalance: Double? = actualMilesDifference!/projectedMilesPerDay!
                
                self.actualMilesPerDayLabel.text = NSString(format: "%.1f", actualMilesPerDay) as String
                self.actualTotalMilesLabel.text = NSString(format: "%.1f", actualTotalMiles) as String
                self.actualTotalDaysLabel.text = NSString(format: "%d", dateDifference) as String
                self.balanceDaysLabel.text = NSString(format: "%.1f", actualMileageBalance!) as String
                self.milesDifferenceLabel.text = NSString(format: "%.1f", actualMilesDifference!) as String
           } else {
                let actualTotalMiles = Double(miles)
                let actualMilesPerDay = actualTotalMiles/(365.25 * 3.0)
                let actualMileageBalance = 0.0
                let actualMilesDifference = 0.0

                self.actualMilesPerDayLabel.text = NSString(format: "%.1f", actualMilesPerDay) as String
                self.actualTotalMilesLabel.text = NSString(format: "%.1f", actualTotalMiles) as String
                self.actualTotalDaysLabel.text = NSString(format: "%d", dateDifference) as String
                self.balanceDaysLabel.text = NSString(format: "%.1f", actualMileageBalance) as String
                self.milesDifferenceLabel.text = NSString(format: "%.1f", actualMilesDifference) as String
            }
        }
    }
    
    func getStartingMileage() {
        let ac = UIAlertController(title: "Initialization", message: "Enter Starting Values", preferredStyle: .alert)
        ac.addTextField { (dateTextField) in
            dateTextField.placeholder = "Date MM/DD/YYYY"
            dateTextField.clearButtonMode = UITextFieldViewMode.whileEditing
            dateTextField.keyboardType = .numbersAndPunctuation
            dateTextField.becomeFirstResponder()
        }
        ac.addTextField { (mileageTextField) in
            mileageTextField.placeholder = "Mileage"
            mileageTextField.keyboardType = .numbersAndPunctuation
            mileageTextField.clearButtonMode = UITextFieldViewMode.whileEditing
        }
        
        let action: UIAlertAction? = UIAlertAction(title: "Submit", style: .default) {[ac] (action: UIAlertAction) in
            let startingDate = self.dateFromString(ac.textFields![0].text)
            let startingMiles = ac.textFields![1].text
            
            self.saveStartingValues(startingDate, startingMiles: startingMiles)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            NSLog("Button 0 clicked")
        }

        ac.addAction(action!)
        ac.addAction(cancelAction)
        
        present(ac, animated: true, completion: nil)
    }

    func saveStartingValues(_ startingDate: Date!, startingMiles: String!) {
        var newData: NSMutableDictionary?
        
        if self.data == nil {
            newData = NSMutableDictionary()
            
            let newRecord = NSMutableDictionary()
            newRecord.setObject(startingDate, forKey: "date" as NSCopying)
            newRecord.setObject(startingMiles, forKey: "miles" as NSCopying)
            
            newData!.setObject(newRecord, forKey: "start" as NSCopying)
            newData!.setObject(newRecord, forKey: "current" as NSCopying)
            
            print("newData: \(newData!)")
            
            self.data = newData
            self.selectedDate = Date()
            
            _ = PropertyList.write("LeaseData", plistDict: newData!)
        }
        
        //self.addMileage(startingDate, miles: startingMiles, data: newData!)
        
        let startDict: NSDictionary = self.data?.object(forKey: "start") as! NSDictionary
        let startDate: Date = startDict.object(forKey: "date") as! Date
        let startMiles: Double = Double(startDict.object(forKey: "miles") as! String)!
        
        let dateDifference: Int = self.daysBetweenDate(startDate, to: startingDate)
        let milesDifference: Double = Double(startingMiles)! - startMiles
        
        if dateDifference > 0 {
            //let actualTotalMiles = milesDifference
            //let actualMilesPerDay = actualTotalMiles/Double(dateDifference)
            let actualTotalMiles = ((milesDifference/Double(dateDifference))*365.25)*3
            let actualMilesPerDay = milesDifference/Double(dateDifference)
            
            let projectedMilesPerDay: Double? = Double(self.projectedMilesPerDayLabel.text!)
            let projectedMiles: Double? = projectedMilesPerDay! * Double(dateDifference)
            let actualMilesDifference: Double? = milesDifference - projectedMiles!
            let actualMileageBalance: Double? = actualMilesDifference!/projectedMilesPerDay!
            
            self.actualMilesPerDayLabel.text = NSString(format: "%.1f", actualMilesPerDay) as String
            self.actualTotalMilesLabel.text = NSString(format: "%.1f", actualTotalMiles) as String
            self.actualTotalDaysLabel.text = NSString(format: "%d", dateDifference) as String
            self.balanceDaysLabel.text = NSString(format: "%.1f", actualMileageBalance!) as String
            self.milesDifferenceLabel.text = NSString(format: "%.1f", actualMilesDifference!) as String
        } else {
            let actualTotalMiles = 0.0
            let actualMilesPerDay = 0.0
            let actualMileageBalance = 0.0
            let actualMilesDifference = 0.0
           
            self.actualMilesPerDayLabel.text = NSString(format: "%.1f", actualMilesPerDay) as String
            self.actualTotalMilesLabel.text = NSString(format: "%.1f", actualTotalMiles) as String
            self.actualTotalDaysLabel.text = NSString(format: "%d", dateDifference) as String
            self.balanceDaysLabel.text = NSString(format: "%.1f", actualMileageBalance) as String
            self.milesDifferenceLabel.text = NSString(format: "%.1f", actualMilesDifference) as String
        }
    }
    
    func addMileage(_ date: Date, miles: String, data: NSMutableDictionary) {
        let newRecord = NSMutableDictionary()
        newRecord.setObject(date, forKey: "date" as NSCopying)
        newRecord.setObject(miles, forKey: "miles" as NSCopying)
        
        data.setObject(newRecord, forKey: self.currentDate(date) as NSCopying)
        data.setObject(newRecord, forKey: "current" as NSCopying)

        _ = PropertyList.write("LeaseData", plistDict: data)
        
        self.data = data
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func displayDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = DateFormatter.Style.medium
        
        self.selectedDate = Date()
        
        return dateFormatter.string(from: self.selectedDate!)
    }
    
    func dateFromString(_ date: String!) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        return dateFormatter.date(from: date)!
    }
    
    func currentDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy/MM/dd"
        dateFormatter.locale = Locale.current
        
        self.selectedDate = date
        
        return dateFormatter.string(from: self.selectedDate!)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.currentDateTextField {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.75)
            self.datePicker.datePickerMode = UIDatePickerMode.date
            textField.inputView = self.datePicker
            textField.inputAccessoryView = self.inputAccessoryToolBar
            self.datePicker.addTarget(self, action: #selector(EntryViewController.handleDatePicker(_:)), for: UIControlEvents.valueChanged)
            CATransaction.commit()
        }
        
        return true
    }
    
    @objc func handleDatePicker(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = DateFormatter.Style.medium
        
        self.selectedDate = sender.date
        self.currentDateTextField.text = dateFormatter.string(from: sender.date)
    }
    
    @IBAction func done(_ sender: AnyObject) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.75)
        self.currentDateTextField.resignFirstResponder()
        CATransaction.commit()
    }
    
    @IBAction func doneMileage(_ sender: AnyObject) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.75)
        self.mileageTextField.resignFirstResponder()
        CATransaction.commit()
    }
    
    @IBAction func addMileageAction(_ sender: AnyObject) {
        self.addNewMileage(self)
    }
    
    @IBAction func addNewMileage(_ sender: AnyObject) {
        let miles = self.mileageTextField.text!
        
        let startDict: NSDictionary = self.data?.object(forKey: "start") as! NSDictionary
        let startDate: Date = startDict.object(forKey: "date") as! Date
        let startMiles: Double = Double(startDict.object(forKey: "miles") as! String)!
        
        let dateDifference: Int = self.daysBetweenDate(startDate, to: self.selectedDate!)
        let milesDifference: Double = Double(miles)! - startMiles
        
        if dateDifference > 0 {
            //let actualTotalMiles = milesDifference
            //let actualMilesPerDay = actualTotalMiles/Double(dateDifference)
            let actualTotalMiles = ((milesDifference/Double(dateDifference))*365.25)*3
            let actualMilesPerDay = milesDifference/Double(dateDifference)
            
            let projectedMilesPerDay: Double? = Double(self.projectedMilesPerDayLabel.text!)
            let projectedMiles: Double? = projectedMilesPerDay! * Double(dateDifference)
            let actualMilesDifference: Double? = milesDifference - projectedMiles!
            let actualMileageBalance: Double? = actualMilesDifference!/projectedMilesPerDay!
            
            self.actualMilesPerDayLabel.text = NSString(format: "%.1f", actualMilesPerDay) as String
            self.actualTotalMilesLabel.text = NSString(format: "%.1f", actualTotalMiles) as String
            self.actualTotalDaysLabel.text = NSString(format: "%d", dateDifference) as String
            self.balanceDaysLabel.text = NSString(format: "%.1f", actualMileageBalance!) as String
            self.milesDifferenceLabel.text = NSString(format: "%.1f", actualMilesDifference!) as String
        } else {
            let actualTotalMiles = Double(miles)!
            let actualMilesPerDay = actualTotalMiles/(365.25 * 3.0)
            let actualMileageBalance = 0.0
            let actualMilesDifference = 0.0
            
            self.actualMilesPerDayLabel.text = NSString(format: "%.1f", actualMilesPerDay) as String
            self.actualTotalMilesLabel.text = NSString(format: "%.1f", actualTotalMiles) as String
            self.actualTotalDaysLabel.text = NSString(format: "%d", dateDifference) as String
            self.balanceDaysLabel.text = NSString(format: "%.1f", actualMileageBalance) as String
            self.milesDifferenceLabel.text = NSString(format: "%.1f", actualMilesDifference) as String
       }
        self.mileageTextField.text = ""
        self.mileageTextField.resignFirstResponder()
        
        self.addMileage(self.selectedDate!, miles: miles, data: self.data!)
    }
    
    func daysBetweenDate(_ from: Date, to: Date) -> Int {
        let currentDate = Calendar.current
        
        guard let start = currentDate.ordinality(of: .day, in: .era, for: from) else {
            return 0
        }
        guard let end = currentDate.ordinality(of: .day, in: .era, for: to) else {
            return 0
        }
        
        return end - start
    }
    
    func getStartingMileageOld() {
        let title: String = "Mileage"
        let buttons: Array = ["Cancel", "OK"]
        let msg: String = "Enter Starting Mileage"
        var inputTextField: UITextField?
        
        let alertController: UIAlertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: buttons[0], style: .cancel) { action in
            NSLog("Button 0 clicked")
        }
        
        let okAction = UIAlertAction(title: buttons[1], style: .default) { action in
            let miles = inputTextField!.text
            let date = self.selectedDate
            var newData: NSMutableDictionary?
            
            if self.data == nil {
                newData = NSMutableDictionary()
                
                let newRecord = NSMutableDictionary()
                newRecord.setObject(date!, forKey: "date" as NSCopying)
                newRecord.setObject(miles!, forKey: "miles" as NSCopying)
                
                newData!.setObject(newRecord, forKey: "start" as NSCopying)
                newData!.setObject(newRecord, forKey: "current" as NSCopying)
                
                _ = PropertyList.write("LeaseData", plistDict: newData!)
            }
            
            self.addMileage(date!, miles: miles!, data: newData!)
            
            let startDict: NSDictionary = self.data?.object(forKey: "start") as! NSDictionary
            let startDate: Date = startDict.object(forKey: "date") as! Date
            let startMiles: Double = Double(startDict.object(forKey: "miles") as! String)!
            
            let dateDifference: Int = self.daysBetweenDate(startDate, to: date!)
            let milesDifference: Double = Double(miles!)! - startMiles
            
            if dateDifference > 0 {
                //let actualTotalMiles = milesDifference
                //let actualMilesPerDay = actualTotalMiles/Double(dateDifference)
                let actualTotalMiles = ((milesDifference/Double(dateDifference))*365.25)*3
                let actualMilesPerDay = milesDifference/Double(dateDifference)
                
                self.actualMilesPerDayLabel.text = NSString(format: "%.1f", actualMilesPerDay) as String
                self.actualTotalMilesLabel.text = NSString(format: "%.1f", actualTotalMiles) as String
                self.actualTotalDaysLabel.text = NSString(format: "%d", dateDifference) as String
            } else {
                let actualTotalMiles = 0.0
                let actualMilesPerDay = 0.0
                
                self.actualMilesPerDayLabel.text = NSString(format: "%.1f", actualMilesPerDay) as String
                self.actualTotalMilesLabel.text = NSString(format: "%.1f", actualTotalMiles) as String
                self.actualTotalDaysLabel.text = NSString(format: "%d", dateDifference) as String
            }
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Enter Starting Mileage"
            textField.becomeFirstResponder()
            textField.keyboardType = .decimalPad
            textField.textAlignment = .center
            inputTextField = textField
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }

}
