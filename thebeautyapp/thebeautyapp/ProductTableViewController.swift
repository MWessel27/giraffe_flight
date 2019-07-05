//
//  productViewController.swift
//  thebeautyapp
//
//  Created by Mikalangelo Wessel on 6/3/18.
//  Copyright © 2018 giraffeflight. All rights reserved.
//

import UIKit
import os.log
import Firebase
import UserNotifications

class ProductTableViewController: UITableViewController {
    
    var products = [Product]()
    
    @IBOutlet var productTableView: UITableView!
    
    @IBOutlet weak var reminderSwitch: UISwitch!
    @IBOutlet weak var reminderView: UIView!
    @IBOutlet weak var reminderTimePicker: UIDatePicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightBarButton = UIBarButtonItem(title: "ADD", style: UIBarButtonItem.Style.plain, target: self, action: #selector(addProdList))
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        if let savedProds = loadProducts() {
            products += savedProds
        }
        
        if(products.count == 0) {
            reminderView.isHidden = true
        } else {
            reminderView.isHidden = false
            let defaults = UserDefaults.standard
            
            if (defaults.object(forKey: "ReminderSwitchState") != nil) {
                reminderSwitch.isOn = defaults.bool(forKey: "ReminderSwitchState")
            }
            
            let center = UNUserNotificationCenter.current()

            center.getPendingNotificationRequests(completionHandler: { requests in
                var nextTriggerDates: [Date] = []
                for request in requests {
                    print(request)
                    if let trigger = request.trigger as? UNCalendarNotificationTrigger,
                        let triggerDate = trigger.nextTriggerDate(){
                        nextTriggerDates.append(triggerDate)
                    }

                    if let nextTriggerDate = nextTriggerDates.min() {
                        print(nextTriggerDate)
                        self.setDateForPicker(pickerDate: nextTriggerDate)
                    }
                }
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        if let savedProds = loadProducts() {
            products = savedProds
        }

        productTableView.reloadData()
        
        if(products.count == 0) {
            reminderView.isHidden = true
        } else {
            reminderView.isHidden = false
            let defaults = UserDefaults.standard
            
            if (defaults.object(forKey: "ReminderSwitchState") != nil) {
                reminderSwitch.isOn = defaults.bool(forKey: "ReminderSwitchState")
            }
            
            let center = UNUserNotificationCenter.current()
            
            center.getPendingNotificationRequests(completionHandler: { requests in
                var nextTriggerDates: [Date] = []
                for request in requests {
                    print(request)
                    if let trigger = request.trigger as? UNCalendarNotificationTrigger,
                        let triggerDate = trigger.nextTriggerDate(){
                        nextTriggerDates.append(triggerDate)
                    }
                    
                    if let nextTriggerDate = nextTriggerDates.min() {
                        print(nextTriggerDate)
                        self.setDateForPicker(pickerDate: nextTriggerDate)
                    }
                }
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);

        if let savedProds = loadProducts() {
            products = savedProds
        }
        productTableView.reloadData()
        
        if(products.count == 0) {
            reminderView.isHidden = true
        } else {
            reminderView.isHidden = false
            let defaults = UserDefaults.standard
            
            if (defaults.object(forKey: "ReminderSwitchState") != nil) {
                reminderSwitch.isOn = defaults.bool(forKey: "ReminderSwitchState")
            }
            
            let center = UNUserNotificationCenter.current()
            
            center.getPendingNotificationRequests(completionHandler: { requests in
                var nextTriggerDates: [Date] = []
                for request in requests {
                    print(request)
                    if let trigger = request.trigger as? UNCalendarNotificationTrigger,
                        let triggerDate = trigger.nextTriggerDate(){
                        nextTriggerDates.append(triggerDate)
                    }
                    
                    if let nextTriggerDate = nextTriggerDates.min() {
                        print(nextTriggerDate)
                        self.setDateForPicker(pickerDate: nextTriggerDate)
                    }
                }
            })
        }
    }
    
    
    @objc func addProdList() {
        let storyBoard : UIStoryboard = self.storyboard!
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "newProductViewController")
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func saveProducts() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(products, toFile: Product.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Products successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save Products...", log: OSLog.default, type: .error)
        }
    }
    
    
    private func loadProducts() -> [Product]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Product.ArchiveURL.path) as? [Product]
    }
    
    @IBAction func unwindToProductList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? newProductViewController, let product = sourceViewController.product {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                products[selectedIndexPath.row] = product
                productTableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                // Add a new product
                let newIndexPath = IndexPath(row: products.count, section: 0)
                
                products.append(product)
                productTableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            saveProducts()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch(segue.identifier ?? "") {
        case "AddItem":
            os_log("Adding a new meal.", log: OSLog.default, type: .debug)
        case "ShowDetail":
            guard let productDetailViewController = segue.destination as? newProductViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }

            guard let selectedProductCell = sender as? ProductTableViewCell else {
                fatalError("Unexpected sender: \(sender as Optional)")
            }

            guard let indexPath = productTableView.indexPath(for: selectedProductCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }

            let selectedProduct = products[indexPath.row]
            productDetailViewController.product = selectedProduct
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier as Optional)")
        }
    }
    
    func getReminderSwitchState() -> Bool {
        var reminderOnOff = false
        
        if(self.reminderSwitch.isOn) {
            reminderOnOff = true
        }
        
        return reminderOnOff
    }
    
    func getDateFromPicker() -> Date {
        var reminderDate = Date()

        reminderDate = self.reminderTimePicker.date
        
        return reminderDate
    }
    
    func setDateForPicker(pickerDate: Date) {
        DispatchQueue.global().async(execute: {
            DispatchQueue.main.sync{
                self.reminderTimePicker.date = pickerDate
            }
        })
    }
    
    func scheduleNotification() {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Skin Care Reminder"
        content.body = "Time to complete your daily skin care routine."
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default
        
        let reminderDate = getDateFromPicker()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH mm"
        let reminderTime = dateFormatter.string(from: reminderDate)

        dateFormatter.dateFormat = "HH"
        let hour = dateFormatter.string(from: reminderDate)
        dateFormatter.dateFormat = "mm"
        let minute = dateFormatter.string(from: reminderDate)
        print(hour)
        print(minute)
        
        var dateComponents = DateComponents()
        dateComponents.hour = Int(hour)!
        dateComponents.minute = Int(minute)!
        
        if(getReminderSwitchState()) {
            Analytics.logEvent("reminder_on", parameters: [
                "time": reminderTime as NSObject
                ])
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
    }
    
    @IBAction func reminderTimePickerChanged(_ sender: Any) {
        let defaults = UserDefaults.standard
        print(self.reminderTimePicker.date)
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        self.scheduleNotification()
        defaults.set(true, forKey: "ReminderSwitchState")
    }
    
    
    @IBAction func reminderToggle(_ sender: Any) {
        
        let defaults = UserDefaults.standard
        
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Notification Permissions On")
            } else {
                print("Notification Permissions Off")
            }
        }
        
        if reminderSwitch.isOn {
            print("Scheduling notification")
            self.scheduleNotification()
            defaults.set(true, forKey: "ReminderSwitchState")
        } else {
            Analytics.logEvent("reminder_off", parameters: nil)
            print("Cleared notification")
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            defaults.set(false, forKey: "ReminderSwitchState")
        }
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Analytics.logEvent("remove_product", parameters: [
                "productName": products[indexPath.row].name as NSObject
                ])
            // Delete the row from the data source
            products.remove(at: indexPath.row)
            saveProducts()
            productTableView.deleteRows(at: [indexPath], with: .fade)
            if(products.count == 0) {
                let defaults = UserDefaults.standard
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

                defaults.set(false, forKey: "ReminderSwitchState")
                reminderView.isHidden = true
            } else {
                let defaults = UserDefaults.standard
                
                if (defaults.object(forKey: "ReminderSwitchState") != nil) {
                    reminderSwitch.isOn = defaults.bool(forKey: "ReminderSwitchState")
                }
                
                let center = UNUserNotificationCenter.current()
                
                center.getPendingNotificationRequests(completionHandler: { requests in
                    var nextTriggerDates: [Date] = []
                    for request in requests {
                        print(request)
                        if let trigger = request.trigger as? UNCalendarNotificationTrigger,
                            let triggerDate = trigger.nextTriggerDate(){
                            nextTriggerDates.append(triggerDate)
                        }
                        
                        if let nextTriggerDate = nextTriggerDates.min() {
                            print(nextTriggerDate)
                            self.setDateForPicker(pickerDate: nextTriggerDate)
                        }
                    }
                })
                reminderView.isHidden = false
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "ProductTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ProductTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ProductTableViewCell.")
        }
        
        let product = products[indexPath.row]
        
        cell.productLabel.text = product.name
        cell.productLabel.font = UIFont(name: "American Typewriter", size: 22)
        
        let timeOfDay = products[indexPath.row].ampm
        
        if(timeOfDay == 1) {
            cell.photoImageView.image = UIImage(named: "sunIconSmall.png")!
        } else if(timeOfDay == 2) {
            cell.photoImageView.image = UIImage(named: "moonIconSmall.png")!
        } else {
            cell.photoImageView.image = UIImage(named: "sunMoonIcon.png")!
        }
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
}
