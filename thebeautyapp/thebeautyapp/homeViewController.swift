//
//  ViewController.swift
//  thebeautyapp
//
//  Created by Mikalangelo Wessel on 5/21/18.
//  Copyright © 2018 giraffeflight. All rights reserved.
//
//  MW TODO
//          - No products for current day
//          - Constraints
//

import UIKit
import CoreData
import os.log
import Firebase

class homeViewController: UIViewController, addEditProduct {
    
    private let imageView = UIImageView(image: UIImage(named: "notifications-icon"))
    
    @IBOutlet weak var addIconImageView: UIImageView!
    @IBOutlet weak var noProductIcon: UIImageView!
    
    @IBOutlet var homeBackgroundView: UIView!
    
    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet weak var pmTableView: UITableView!
    
    @IBOutlet weak var dayIcon: UIImageView!
    @IBOutlet weak var nightIcon: UIImageView!
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var nightLabel: UILabel!
    
    @IBOutlet weak var dayProductEditButton: UIButton!
    @IBOutlet weak var nightProductEditButton: UIButton!
    
    @IBOutlet weak var cellSelectionIcon: UIImageView!
    @IBOutlet weak var cellLabel: UILabel!
    
    var products = [Product]()
    
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
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView

        // Your action
        print("notifications tapped")
        guard let notificationsVC = storyboard?.instantiateViewController(withIdentifier: "NotificationsViewController")
        as? NotificationsViewController else {
            assertionFailure("No view controller ID NotificationsViewController in storyboard")
            return
        }
        
        // Delay the capture of snapshot by 0.1 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 , execute: {
          // take a snapshot of current view and set it as backingImage
          notificationsVC.backingImage = self.tabBarController?.view.asImage()
          
          // present the view controller modally without animation
          self.present(notificationsVC, animated: false, completion: nil)
        })
    }
    
    @objc func addIconImageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView

        // Your action
        print("notifications tapped")
        guard let addProductVC = storyboard?.instantiateViewController(withIdentifier: "AddProductViewController")
        as? AddProductViewController else {
            assertionFailure("No view controller ID AddProductViewController in storyboard")
            return
        }
        
        addProductVC.delegate = self
        
        // Delay the capture of snapshot by 0.1 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 , execute: {
          // take a snapshot of current view and set it as backingImage
          addProductVC.backingImage = self.tabBarController?.view.asImage()
          
          // present the view controller modally without animation
          self.present(addProductVC, animated: false, completion: nil)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        let addGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addIconImageTapped(tapGestureRecognizer:)))
        addIconImageView.isUserInteractionEnabled = true
        addIconImageView.addGestureRecognizer(addGestureRecognizer)
        
        // returns an integer from 1 - 7, with 1 being Sunday and 7 being Saturday
        dayOfWeek = Date().dayNumberOfWeek()!
        
        if let savedProds = loadProducts() {
            products += savedProds
        }
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        todaysDate = formatter.string(from: date)
        
        if(products.count != 0) {
            noProductIcon.isHidden = true
            addIconImageView.isHidden = true
            
            mTableView.tableFooterView = UIView(frame: CGRect.zero)
            pmTableView.tableFooterView = UIView(frame: CGRect.zero)
            
            mTableView.backgroundColor = UIColor.clear
            mTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
            
            pmTableView.backgroundColor = UIColor.clear
            pmTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        } else {
            noProductIcon.isHidden = false
            addIconImageView.isHidden = false

            dayIcon.isHidden = true
            nightIcon.isHidden = true
            dayLabel.isHidden = true
            nightLabel.isHidden = true
            dayProductEditButton.isHidden = true
            nightProductEditButton.isHidden = true
            
            mTableView.isHidden = true;
            pmTableView.isHidden = true;
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        if let savedProds = loadProducts() {
            products = savedProds
        }
        
        if(products.count != 0) {
            noProductIcon.isHidden = true
            addIconImageView.isHidden = true
            
            dayIcon.isHidden = false
            nightIcon.isHidden = false
            dayLabel.isHidden = false
            nightLabel.isHidden = false
            dayProductEditButton.isHidden = false
            nightProductEditButton.isHidden = false

            mTableView.isHidden = false;
            pmTableView.isHidden = false;
            
            mTableView.tableFooterView = UIView(frame: CGRect.zero)
            pmTableView.tableFooterView = UIView(frame: CGRect.zero)
            
            mTableView.backgroundColor = UIColor.clear
            mTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
            
            pmTableView.backgroundColor = UIColor.clear
            pmTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        } else {
            noProductIcon.isHidden = false
            addIconImageView.isHidden = false
            
            dayIcon.isHidden = true
            nightIcon.isHidden = true
            dayLabel.isHidden = true
            nightLabel.isHidden = true
            dayProductEditButton.isHidden = true
            nightProductEditButton.isHidden = true

            mTableView.isHidden = true;
            pmTableView.isHidden = true;
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
            noProductIcon.isHidden = true
            addIconImageView.isHidden = true
            
            dayIcon.isHidden = false
            nightIcon.isHidden = false
            dayLabel.isHidden = false
            nightLabel.isHidden = false
            dayProductEditButton.isHidden = false
            nightProductEditButton.isHidden = false

            mTableView.isHidden = false;
            pmTableView.isHidden = false;
            
            mTableView.tableFooterView = UIView(frame: CGRect.zero)
            pmTableView.tableFooterView = UIView(frame: CGRect.zero)
            
            mTableView.backgroundColor = UIColor.clear
            mTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
            
            pmTableView.backgroundColor = UIColor.clear
            pmTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        } else {
            noProductIcon.isHidden = false
            addIconImageView.isHidden = false
            
            dayIcon.isHidden = true
            nightIcon.isHidden = true
            dayLabel.isHidden = true
            nightLabel.isHidden = true
            dayProductEditButton.isHidden = true
            nightProductEditButton.isHidden = true

            mTableView.isHidden = true;
            pmTableView.isHidden = true;
        }
        
        self.mTableView.reloadData();
        self.pmTableView.reloadData();
    }
    
    private func loadProducts() -> [Product]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Product.ArchiveURL.path) as? [Product]
    }
    
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true

        title = "Today"

        // Initial setup for image for Large NavBar state since the the screen always has Large NavBar once it gets opened
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        navigationBar.addSubview(imageView)
        imageView.layer.cornerRadius = Const.ImageSizeForLargeState / 2
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -Const.ImageRightMargin),
            imageView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -Const.ImageBottomMarginForLargeState),
            imageView.heightAnchor.constraint(equalToConstant: Const.ImageSizeForLargeState),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
            ])
    }
    
    @IBAction func editDayProductButtonClicked(_ sender: Any) {
        if(mTableView.isEditing) {
            mTableView.isEditing = false
            dayProductEditButton.setTitle("Edit", for: .normal)
        } else {
            mTableView.isEditing = true
            dayProductEditButton.setTitle("Done", for: .normal)
        }
    }
    
    @IBAction func editNightProductButtonClicked(_ sender: Any) {
        if(pmTableView.isEditing) {
            pmTableView.isEditing = false
            nightProductEditButton.setTitle("Edit", for: .normal)
        } else {
            pmTableView.isEditing = true
            nightProductEditButton.setTitle("Done", for: .normal)
        }
    }
    
    
    @IBAction func addProductButtonClicked(_ sender: Any) {
        if let presentedViewController = self.storyboard?.instantiateViewController(withIdentifier: "newProductViewController") {
            presentedViewController.providesPresentationContextTransitionStyle = true
            presentedViewController.definesPresentationContext = true
            presentedViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext;
            presentedViewController.view.backgroundColor = UIColor.init(white: 0.4, alpha: 0.8)
            self.present(presentedViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func unwindToProductList(sender: UIStoryboardSegue) {
        self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
        if let sourceViewController = sender.source as? newProductViewController, let product = sourceViewController.product {
            products.append(product)
            saveProducts()
        }
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
        
        for act in product.usedActivities {
            if(act.date == todaysDate && act.ampm == ampm) {
                print("prod already used today")
                return
            }
        }
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let currentTime = formatter.string(for: date)
        var ampmReadable = "Unknown"
        
        if(ampm == 1) {
            ampmReadable = "Morning"
        } else {
            ampmReadable = "Night"
        }
        
        Analytics.logEvent("product_checked_for_day", parameters: [
            "productName": product.name as NSObject,
            "dateUsed": todaysDate as NSObject,
            "timeUsed": currentTime! as NSObject,
            "usedIn": ampmReadable as NSObject
            ])

        let usedActivity = UsedActivity(productName: product.name , date: todaysDate, ampm: ampm, time: currentTime!)
        
        product.usedActivities.append(usedActivity!)
        
        saveProducts()
    }
    
    func addProduct(product: Product) {
        products.append(product)
        saveProducts()
    }
    
    func removeUsedActivity(product: Product, ampm: Int) {
        
        for (index, act) in product.usedActivities.enumerated() {
            if(act.date == todaysDate && act.ampm == ampm) {
                product.usedActivities.remove(at: index)
                saveProducts()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "HomeTableViewCell"
        
        let cell:HomeTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! HomeTableViewCell
        
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
                var timeStamp = ""
                for usedProductDates in products[indexPath.row].usedActivities {
                    if(usedProductDates.date == todaysDate && (usedProductDates.ampm == 1 || usedProductDates.ampm == 0)) {
                        timeStamp = usedProductDates.time
                        checked = true
                    }
                }
                
                let productName = products[indexPath.row].name
                cell.cellLabel.text = productName
                
                if(checked) {
                    cell.cellLabel.font = UIFont(name: "System", size: 24)
                    cell.productDetailTextLabel?.backgroundColor = UIColor.clear
                    cell.productDetailTextLabel?.font = UIFont(name: "System", size: 10)
                    cell.productDetailTextLabel?.textColor = UIColor.gray
                    cell.productDetailTextLabel?.text = timeStamp
                    
                    cell.tintColor = UIColor.white
                    cell.backgroundColor = UIColor.clear
                    
                    cell.cellSelectedImage.image = UIImage(named: "checkmark.png")!
                } else {
                    cell.cellLabel.font = UIFont(name: "System", size: 24)
                    cell.cellLabel.backgroundColor = UIColor.clear
                    cell.productDetailTextLabel?.backgroundColor = UIColor.clear
                    cell.productDetailTextLabel?.text = ""
                    cell.cellSelectedImage.image = UIImage(named: "checkmarkempty.png")!
                }
                return cell
            } else {
                cell.isHidden = true
            }
        } else {
            if((products[indexPath.row].ampm == 2 || products[indexPath.row].ampm == 0)  && productValidForDay) {
                
                var checked = false
                var timeStamp = ""
                for usedProductDates in products[indexPath.row].usedActivities {
                    if(usedProductDates.date == todaysDate && (usedProductDates.ampm == 2 || usedProductDates.ampm == 0)) {
                        timeStamp = usedProductDates.time
                        checked = true
                    }
                }
                
                let productName = products[indexPath.row].name
                cell.cellLabel.text = productName
                
                if(checked) {
                    cell.cellLabel.font = UIFont(name: "System", size: 24)
                    cell.productDetailTextLabel?.backgroundColor = UIColor.clear
                    cell.productDetailTextLabel?.font = UIFont(name: "System", size: 10)
                    cell.productDetailTextLabel?.textColor = UIColor.gray
                    cell.productDetailTextLabel?.text = timeStamp
                    
                    cell.tintColor = UIColor.white
                    cell.backgroundColor = UIColor.clear
                    
                    cell.cellSelectedImage.image = UIImage(named: "checkmark.png")!
                } else {
                    cell.cellLabel.font = UIFont(name: "System", size: 24)
                    cell.cellLabel.backgroundColor = UIColor.clear
                    cell.productDetailTextLabel?.backgroundColor = UIColor.clear
                    cell.productDetailTextLabel?.text = ""
                    cell.cellSelectedImage.image = UIImage(named: "checkmarkempty.png")!
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
        
        let mySelectedCell = tableView.cellForRow(at: indexPath) as! HomeTableViewCell
        
        var ampm = 3
        if(tableView == mTableView) {
            ampm = 1
        } else {
            ampm = 2
        }
        
        // need to change this to cells having a selected state
        if(mySelectedCell.productDetailTextLabel?.text != "") {
            removeUsedActivity(product: products[indexPath.row], ampm: ampm)
            mySelectedCell.cellLabel.font = UIFont(name: "System", size: 24)
            mySelectedCell.cellLabel.backgroundColor = UIColor.clear
            mySelectedCell.productDetailTextLabel?.backgroundColor = UIColor.clear
            mySelectedCell.productDetailTextLabel?.text = ""
            mySelectedCell.cellSelectedImage.image = UIImage(named: "checkmarkempty.png")!
        } else {
            addUsedActivity(product: products[indexPath.row], ampm: ampm)
            mySelectedCell.cellLabel.font = UIFont(name: "System", size: 24)
            mySelectedCell.productDetailTextLabel?.backgroundColor = UIColor.clear
            mySelectedCell.productDetailTextLabel?.font = UIFont(name: "System", size: 10)
            mySelectedCell.productDetailTextLabel?.textColor = UIColor.gray
            
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            let currentTime = formatter.string(for: date)
            mySelectedCell.productDetailTextLabel?.text = currentTime
            
            mySelectedCell.cellSelectedImage.image = UIImage(named: "checkmark.png")!
            mySelectedCell.tintColor = UIColor.white
            mySelectedCell.backgroundColor = UIColor.clear
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedProduct = self.products[sourceIndexPath.row]
        products.remove(at: sourceIndexPath.row)
        products.insert(movedProduct, at: destinationIndexPath.row)
        saveProducts()
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> HomeTableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}

private struct Const {
    /// Image height/width for Large NavBar state
    static let ImageSizeForLargeState: CGFloat = 32
    /// Margin from right anchor of safe area to right anchor of Image
    static let ImageRightMargin: CGFloat = 16
    /// Margin from bottom anchor of NavBar to bottom anchor of Image for Large NavBar state
    static let ImageBottomMarginForLargeState: CGFloat = 12
    /// Margin from bottom anchor of NavBar to bottom anchor of Image for Small NavBar state
    static let ImageBottomMarginForSmallState: CGFloat = 6
    /// Image height/width for Small NavBar state
    static let ImageSizeForSmallState: CGFloat = 32
    /// Height of NavBar for Small state. Usually it's just 44
    static let NavBarHeightSmallState: CGFloat = 44
    /// Height of NavBar for Large state. Usually it's just 96.5 but if you have a custom font for the title, please make sure to edit this value since it changes the height for Large state of NavBar
    static let NavBarHeightLargeState: CGFloat = 96.5
}
