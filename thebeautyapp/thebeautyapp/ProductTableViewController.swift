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

protocol addEditProduct {
    func addProduct(product: Product)
}

class ProductTableViewController: UITableViewController, addEditProduct {
    
    private let imageView = UIImageView(image: UIImage(named: "add-icon"))
    
    var products = [Product]()
    
    @IBOutlet var productTableView: UITableView!
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView

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
    
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true

        title = "Products"

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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupUI()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        if let savedProds = loadProducts() {
            products += savedProds
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        if let savedProds = loadProducts() {
            products = savedProds
        }

        productTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);

        if let savedProds = loadProducts() {
            products = savedProds
        }
        productTableView.reloadData()
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
    
    func addProduct(product: Product) {
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
        
        if products.count == 0 {
            tableView.setEmptyView()
        }
        else {
            tableView.restore()
        }
        
        return products.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "ProductTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ProductTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ProductTableViewCell.")
        }
        
        let product = products[indexPath.row]
        
        cell.productLabel.text = product.name
        cell.productLabel.font = UIFont(name: "System", size: 22)
        
        let timeOfDay = products[indexPath.row].ampm
        
        if(timeOfDay == 1) {
            cell.photoImageView.image = UIImage(named: "sun-icon.png")!
        } else if(timeOfDay == 2) {
            cell.photoImageView.image = UIImage(named: "moon-icon.png")!
        } else {
            cell.photoImageView.image = UIImage(named: "sun-moon-icon.png")!
        }
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let addProductVC = storyboard?.instantiateViewController(withIdentifier: "AddProductViewController")
        as? AddProductViewController else {
            assertionFailure("No view controller ID AddProductViewController in storyboard")
            return
        }
        
        addProductVC.delegate = self

        let selectedProduct = products[indexPath.row]
        addProductVC.product = selectedProduct
        
        // Delay the capture of snapshot by 0.1 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 , execute: {
          // take a snapshot of current view and set it as backingImage
          addProductVC.backingImage = self.tabBarController?.view.asImage()
          
          // present the view controller modally without animation
          self.present(addProductVC, animated: false, completion: nil)
        })
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

extension UITableView {
    func setEmptyView() {
        let emptyImageView = UIImageView(image: UIImage(named:  "product_empty_icon.png"))
        emptyImageView.contentMode = .center
        self.backgroundView = emptyImageView
        self.separatorStyle = .none
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
