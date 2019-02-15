//
//  ViewController.swift
//  thebeautyapp
//
//  Created by Mikalangelo Wessel on 5/21/18.
//  Copyright © 2018 giraffeflight. All rights reserved.
//

import UIKit
import CoreData

class homeViewController: UIViewController {
    
    @IBOutlet var homeBackgroundView: UIView!
    
    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet weak var pmTableView: UITableView!
    
    @IBOutlet weak var sunImage: UIImageView!
    @IBOutlet weak var moonImage: UIImageView!
    @IBOutlet weak var gettingStartedBackground: UIImageView!
    
    var products = [Product]()
    var selectedProducts = [Product]()
    
    // saving used products array to use on calendar
    var usedProducts = [UsedProducts]()

    var moc:NSManagedObjectContext!
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
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
        
        moc = appDelegate?.persistentContainer.viewContext
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        todaysDate = formatter.string(from: date)
        usedProducts = [loadData()]
        
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
    
    func loadData() -> UsedProducts {
        let dayRequest:NSFetchRequest<UsedProducts> = UsedProducts.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "added", ascending: false)
        dayRequest.sortDescriptors = [sortDescriptor]
        
        do {
            try usedProducts = moc.fetch(dayRequest)
        } catch {
            print("Could not load data")
        }
        
        // UsedProducts now adds 1 product to the right day
        // need to change productName to an array of strings
        // need to remove products for day when unchecked
        for prod in usedProducts {
            if(prod.added == todaysDate){
//                print(prod.added)
//                print(prod.productName)
                return prod
            }
        }
        let usedProd = UsedProducts(context: moc)
        
        return usedProd
    }
    
    func addProductToDatabase(name: String) {
        let todaysProd: UsedProducts
        todaysProd = loadData()
        if(todaysProd.added == todaysDate) {
            todaysProd.productName = name
            //usedProductList.append(todaysProd)
            appDelegate?.saveContext()
        } else {
            let todaysUsedProducts = UsedProducts(context: moc)
            todaysUsedProducts.added = todaysDate
            todaysUsedProducts.productName = name
            appDelegate?.saveContext()
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
        
        var checked = false
        for usedProd in usedProducts {
            if(products[indexPath.row].name == usedProd.productName){
                checked = true
            }
        }
        
        if(tableView == mTableView) {
            if((products[indexPath.row].ampm == 1 || products[indexPath.row].ampm == 0) && productValidForDay) {
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
        
        if(mySelectedCell.backgroundColor == green) {
            
            for prod in selectedProducts {
                if(prod.name == mySelectedCell.textLabel!.text) {
                    if let index = selectedProducts.index(of: prod) {
                        selectedProducts.remove(at: index)
                    }
                }
            }

            mySelectedCell = setCellUnchecked(cell: mySelectedCell)
        } else {
            selectedProducts.append(products[indexPath.row])
            addProductToDatabase(name: products[indexPath.row].name)
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
