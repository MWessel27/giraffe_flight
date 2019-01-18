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
    //var tempProducts = [String]()
    
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
    
    
    private func loadProducts() -> [Product]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Product.ArchiveURL.path) as? [Product]
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        super.prepare(for: segue, sender: sender)
//
//        switch(segue.identifier ?? "") {
//        case "ShowDetail":
//            guard let productDetailViewController = segue.destination as? newProductViewController else {
//                fatalError("Unexpected destination: \(segue.destination)")
//            }
//
//            guard let selectedProductCell = sender as? ProductTableViewCell else {
//                fatalError("Unexpected sender: \(sender)")
//            }
//
//            guard let indexPath = productTableView.indexPath(for: selectedProductCell) else {
//                fatalError("The selected cell is not being displayed by the table")
//            }
//
//            let selectedProduct = products[indexPath.row]
//            productDetailViewController.product = selectedProduct
//        default:
//            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
//        }
//    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        performSegue(withIdentifier: "ShowDetail", sender: indexPath.row)
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return tempProducts.count
        return products.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "ProductTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ProductTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ProductTableViewCell.")
        }
        //        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier) as? ProductTableViewCell
        
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
        
        //cell.detailTextLabel?.textColor = UIColor.gray
        //cell.detailTextLabel?.text = categoryName
        
        //        cell.textLabel?.text = productName
        //        cell.textLabel?.font = UIFont(name: "American Typewriter", size: 18)
        cell.backgroundColor = UIColor.clear
        
        return cell
    }

}
