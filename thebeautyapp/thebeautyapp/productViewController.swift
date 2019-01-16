//
//  productViewController.swift
//  thebeautyapp
//
//  Created by Mikalangelo Wessel on 6/3/18.
//  Copyright © 2018 giraffeflight. All rights reserved.
//

import UIKit
import os.log

class productViewController: UIViewController {

    var products = [Product]()
    var tempProducts = [String]()
    
    @IBOutlet weak var productTable: UITableView!
    @IBOutlet weak var newProductEntry: UITextField!
    @IBOutlet weak var newProdBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightBarButton = UIBarButtonItem(title: "ADD", style: UIBarButtonItemStyle.plain, target: self, action: #selector(addProdList))
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        if let savedProds = loadProducts() {
            products += savedProds
        }
        
        //loadSampleProducts()
        
        //tempProducts = ["Lotion", "Moisturizer","Lipstick","Exfoliant"]

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        if let savedProds = loadProducts() {
            products = savedProds
        }
        
        productTable.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        if let savedProds = loadProducts() {
            products = savedProds
        }
        
        productTable.reloadData()
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
    
    @IBAction func newProdBtnClick(_ sender: Any) {
        let prodName = newProductEntry.text!
        guard let prod1 = Product(name: prodName, daily: true, rating: 1, ampm: 1, cat: "mine") else {
            fatalError("Unable to instantiate meal1")
        }
        products += [prod1]
        saveProducts()
        //tempProducts.append(newProductEntry.text!)
        newProductEntry.text = ""
        productTable.reloadData()
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension productViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return tempProducts.count
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "productListCell")

        //let productName = tempProducts[indexPath.row]
        let productName = products[indexPath.row].name
        //let categoryName = products[indexPath.row].cat
        let timeOfDay = products[indexPath.row].ampm
        
        var image : UIImage = UIImage(named: "sunIconSmall.png")!
        
        if(timeOfDay == 2) {
            image = UIImage(named: "moonIconSmall.png")!
        }
        
        cell.imageView?.image = image
        cell.detailTextLabel?.textColor = UIColor.gray
        //cell.detailTextLabel?.text = categoryName
        
        cell.textLabel?.text = productName
        cell.textLabel?.font = UIFont(name: "American Typewriter", size: 18)
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
}

