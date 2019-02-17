//
//  ViewController.swift
//  thebeautyapp
//
//  Created by Mikalangelo Wessel on 5/21/18.
//  Copyright © 2018 giraffeflight. All rights reserved.
//

import UIKit
import CoreData
import os.log

class homeViewController: UIViewController {
    
    @IBOutlet var homeBackgroundView: UIView!
    
    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet weak var pmTableView: UITableView!
    
    @IBOutlet weak var sunImage: UIImageView!
    @IBOutlet weak var moonImage: UIImageView!
    @IBOutlet weak var gettingStartedBackground: UIImageView!
    
    var products = [Product]()
    var selectedProducts = [Product]()
    
    var todaysDate: String = ""
    
    var dayOfWeek = 0
    
    let green:UIColor = UIColor(red: 0.251, green: 0.831, blue: 0.494, alpha: 1)
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // returns an integer from 1 - 7, with 1 being Sunday and 7 being Saturday
        dayOfWeek = Date().dayNumberOfWeek()!
        
        if let savedProds = loadProducts() {
            products += savedProds
        }
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        todaysDate = formatter.string(from: date)
        
        //to-do update UsedActivity to accept AM/PM & check for each
        
        let rightBarButton = UIBarButtonItem(title: "PRODUCTS", style: UIBarButtonItemStyle.plain, target: self, action: #selector(goToProdList))
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        let leftBarButton = UIBarButtonItem(title: "STATS", style: UIBarButtonItemStyle.plain, target: self, action: #selector(goToStatsCal))
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        if(products.count != 0) {
            mTableView.tableFooterView = UIView(frame: CGRect.zero)
            pmTableView.tableFooterView = UIView(frame: CGRect.zero)
            
            mTableView.backgroundColor = UIColor.clear
            mTableView.separatorStyle = UITableViewCellSeparatorStyle.none
            
            pmTableView.backgroundColor = UIColor.clear
            pmTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        } else {
            sunImage.isHidden = true;
            moonImage.isHidden = true;
            mTableView.isHidden = true;
            pmTableView.isHidden = true;
            
            gettingStartedBackground.isHidden = false;
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        if let savedProds = loadProducts() {
            products = savedProds
        }
        
        if(products.count != 0) {
            gettingStartedBackground.isHidden = true;
            sunImage.isHidden = false;
            moonImage.isHidden = false;
            mTableView.isHidden = false;
            pmTableView.isHidden = false;
            
            mTableView.tableFooterView = UIView(frame: CGRect.zero)
            pmTableView.tableFooterView = UIView(frame: CGRect.zero)
            
            mTableView.backgroundColor = UIColor.clear
            mTableView.separatorStyle = UITableViewCellSeparatorStyle.none
            
            pmTableView.backgroundColor = UIColor.clear
            pmTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        } else {
            sunImage.isHidden = true;
            moonImage.isHidden = true;
            mTableView.isHidden = true;
            pmTableView.isHidden = true;
            
            gettingStartedBackground.isHidden = false;
        }
        
        self.mTableView.reloadData();
        self.pmTableView.reloadData();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        if let savedProds = loadProducts() {
            products = savedProds
        }
        
        if(products.count != 0) {
            gettingStartedBackground.isHidden = true;
            sunImage.isHidden = false;
            moonImage.isHidden = false;
            mTableView.isHidden = false;
            pmTableView.isHidden = false;
            
            mTableView.tableFooterView = UIView(frame: CGRect.zero)
            pmTableView.tableFooterView = UIView(frame: CGRect.zero)
            
            mTableView.backgroundColor = UIColor.clear
            mTableView.separatorStyle = UITableViewCellSeparatorStyle.none
            
            pmTableView.backgroundColor = UIColor.clear
            pmTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        } else {
            sunImage.isHidden = true;
            moonImage.isHidden = true;
            mTableView.isHidden = true;
            pmTableView.isHidden = true;
            
            gettingStartedBackground.isHidden = false;
        }
        
        self.mTableView.reloadData();
        self.pmTableView.reloadData();
    }
    
    private func loadProducts() -> [Product]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Product.ArchiveURL.path) as? [Product]
    }
    
    @objc func goToProdList() {
        performSegue(withIdentifier: "viewProdList", sender: IndexPath.self)
    }
    
    @objc func goToStatsCal() {
        let storyBoard : UIStoryboard = self.storyboard!
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "statsViewController")
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension homeViewController: UITableViewDelegate, UITableViewDataSource {
    
    private func saveProducts() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(products, toFile: Product.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Products successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save Products...", log: OSLog.default, type: .error)
        }
    }
    
    func addUsedActivity(product: Product, ampm: Int) {
        
        for (index, act) in product.usedActivities.enumerated() {
            if(act.date == todaysDate) {
                if(act.ampm == ampm) {
                    print("prod already used today")
                    return
                } else {
                    if(ampm == 1 && act.ampm == 2) {
                        act.ampm = 0
                    } else if(ampm == 2 && act.ampm == 1) {
                        act.ampm = 0
                    } else {
                        act.ampm = ampm
                    }
                    
                    product.usedActivities[index].ampm = act.ampm
                    
                    saveProducts()
                    return
                }
            }
        }

        let usedActivity = UsedActivity(date: todaysDate, ampm: ampm)
        
        product.usedActivities.append(usedActivity!)
        
        saveProducts()
    }
    
    func removeUsedActivity(product: Product, ampm: Int) {
        
        for (index, act) in product.usedActivities.enumerated() {
            if(act.date == todaysDate) {
                if(act.ampm == ampm) {
                    product.usedActivities.remove(at: index)
                    saveProducts()
                } else {
                    if(act.ampm == 0) {
                        if(ampm == 1) {
                            act.ampm = 2
                        } else {
                            act.ampm = 1
                        }
                        
                        product.usedActivities[index].ampm = act.ampm
                        
                        saveProducts()
                        return
                    }
                }
            }
        }
    }
    
    func setCellUnchecked(cell: UITableViewCell) -> UITableViewCell {
        cell.textLabel?.font = UIFont(name: "American Typewriter", size: 22)
        cell.backgroundColor = UIColor.clear
        cell.detailTextLabel?.backgroundColor = UIColor.clear
        cell.detailTextLabel?.text = ""
        
        var imageView : UIImageView
        imageView  = UIImageView(frame:CGRect(x: 5, y: 5, width: 25, height: 25))
        imageView.image = UIImage(named:"checkmarkempty")
        
        cell.accessoryView = imageView
        return cell
    }
    
    func setCellChecked(cell: UITableViewCell) -> UITableViewCell {
        let date = Date()
        
        cell.textLabel?.font = UIFont(name: "American Typewriter", size: 22)
        
        cell.detailTextLabel?.backgroundColor = green
        cell.detailTextLabel?.font = UIFont(name: "American Typewriter", size: 14)
        cell.detailTextLabel?.textColor = UIColor.white
        cell.detailTextLabel?.text = dateFormatter.string(for: date)
        
        var imageView : UIImageView
        imageView  = UIImageView(frame:CGRect(x: 5, y: 5, width: 25, height: 25))
        imageView.image = UIImage(named:"checkmark")
        
        cell.accessoryView = imageView
        cell.tintColor = UIColor.white
        cell.backgroundColor = green
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "ProductCell")
        
        var productValidForDay = false
        
        if(products[indexPath.row].daily) {
            productValidForDay = true
        } else {
            switch(dayOfWeek) {
                case 1:
                    if(products[indexPath.row].onSunday == 1) {
                        productValidForDay = true
                    }
                    break;
                case 2:
                    if(products[indexPath.row].onMonday == 1) {
                        productValidForDay = true
                    }
                    break;
                case 3:
                    if(products[indexPath.row].onTuesday == 1) {
                        productValidForDay = true
                    }
                    break;
                case 4:
                    if(products[indexPath.row].onWednesday == 1) {
                        productValidForDay = true
                    }
                    break;
                case 5:
                    if(products[indexPath.row].onThursday == 1) {
                        productValidForDay = true
                    }
                    break;
                case 6:
                    if(products[indexPath.row].onFriday == 1) {
                        productValidForDay = true
                    }
                    break;
                default:
                    if(products[indexPath.row].onSaturday == 1) {
                        productValidForDay = true
                    }
                    break;
                }
        }
        
        if(tableView == mTableView) {
            if((products[indexPath.row].ampm == 1 || products[indexPath.row].ampm == 0) && productValidForDay) {
                
                var checked = false
                for usedProductDates in products[indexPath.row].usedActivities {
                    if(usedProductDates.date == todaysDate && (usedProductDates.ampm == 1 || usedProductDates.ampm == 0)) {
                        checked = true
                    }
                }
                
                let productName = products[indexPath.row].name
                cell.textLabel?.text = productName
                if(checked) {
                    cell = setCellChecked(cell: cell)
                } else {
                    cell = setCellUnchecked(cell: cell)
                }
                return cell
            } else {
                cell.isHidden = true
            }
        } else {
            if((products[indexPath.row].ampm == 2 || products[indexPath.row].ampm == 0)  && productValidForDay) {
                
                var checked = false
                for usedProductDates in products[indexPath.row].usedActivities {
                    if(usedProductDates.date == todaysDate && (usedProductDates.ampm == 2 || usedProductDates.ampm == 0)) {
                        checked = true
                    }
                }
                
                let productName = products[indexPath.row].name
                cell.textLabel?.text = productName
                if(checked) {
                    cell = setCellChecked(cell: cell)
                } else {
                    cell = setCellUnchecked(cell: cell)
                }
                return cell
            } else {
                cell.isHidden = true
            }
        }
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var rowHeight:CGFloat = 0.0
        
        var productValidForDay = false
        
        if(products[indexPath.row].daily) {
            productValidForDay = true
        } else {
            switch(dayOfWeek) {
                case 1:
                    if(products[indexPath.row].onSunday == 1) {
                        productValidForDay = true
                    }
                    break;
                case 2:
                    if(products[indexPath.row].onMonday == 1) {
                        productValidForDay = true
                    }
                    break;
                case 3:
                    if(products[indexPath.row].onTuesday == 1) {
                        productValidForDay = true
                    }
                    break;
                case 4:
                    if(products[indexPath.row].onWednesday == 1) {
                        productValidForDay = true
                    }
                    break;
                case 5:
                    if(products[indexPath.row].onThursday == 1) {
                        productValidForDay = true
                    }
                    break;
                case 6:
                    if(products[indexPath.row].onFriday == 1) {
                        productValidForDay = true
                    }
                    break;
                default:
                    if(products[indexPath.row].onSaturday == 1) {
                        productValidForDay = true
                    }
                    break;
            }
        }
        
        if(tableView == mTableView) {
            if((products[indexPath.row].ampm == 1 || products[indexPath.row].ampm == 0) && productValidForDay) {
                rowHeight = 50.0
            } else {
                rowHeight = 0.0
            }
        } else {
            if((products[indexPath.row].ampm == 2 || products[indexPath.row].ampm == 0) && productValidForDay) {
                rowHeight = 50.0
            } else {
                rowHeight = 0.0
            }
        }
        return rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var mySelectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        var ampm = 3
        if(tableView == mTableView) {
            ampm = 1
        } else {
            ampm = 2
        }
        
        if(mySelectedCell.backgroundColor == green) {
            
//            for prod in selectedProducts {
//                if(prod.name == mySelectedCell.textLabel!.text) {
//                    if let index = selectedProducts.index(of: prod) {
                        removeUsedActivity(product: products[indexPath.row], ampm: ampm)
//                        selectedProducts.remove(at: index)
//                    }
//                }
//            }

            mySelectedCell = setCellUnchecked(cell: mySelectedCell)
        } else {
            //selectedProducts.append(products[indexPath.row])
            addUsedActivity(product: products[indexPath.row], ampm: ampm)
            mySelectedCell = setCellChecked(cell: mySelectedCell)
        }
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let myHighlightedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        if(myHighlightedCell.backgroundColor == green){
            myHighlightedCell.detailTextLabel?.backgroundColor = UIColor.white
        } else {
            myHighlightedCell.detailTextLabel?.backgroundColor = green
        }
    }
}

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}
