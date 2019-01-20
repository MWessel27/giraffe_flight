//
//  productViewController.swift
//  thebeautyapp
//
//  Created by Mikalangelo Wessel on 6/3/18.
//  Copyright © 2018 giraffeflight. All rights reserved.
//

import UIKit
import os.log

class ProductTableViewController: UITableViewController {
    
    var products = [Product]()
    
    @IBOutlet var productTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightBarButton = UIBarButtonItem(title: "ADD", style: UIBarButtonItemStyle.plain, target: self, action: #selector(addProdList))
        self.navigationItem.rightBarButtonItem = rightBarButton
        
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
    
    
    @objc func addProdList() {
        let storyBoard : UIStoryboard = self.storyboard!
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "newProductViewController")
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    func loadSampleProducts() {
        guard let prod1 = Product(name: "lotion", daily: true, rating: 1, ampm: 1, cat: "mine") else {
            fatalError("Unable to instantiate meal1")
        }
        products += [prod1]
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
                fatalError("Unexpected sender: \(sender)")
            }

            guard let indexPath = productTableView.indexPath(for: selectedProductCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }

            let selectedProduct = products[indexPath.row]
            productDetailViewController.product = selectedProduct
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            products.remove(at: indexPath.row)
            saveProducts()
            productTableView.deleteRows(at: [indexPath], with: .fade)
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
