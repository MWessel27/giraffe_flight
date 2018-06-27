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
        
        tempProducts = ["Lotion", "Moisturizer","Lipstick","Exfoliant"]

        // Do any additional setup after loading the view.
    }
    @IBAction func newProdBtnClick(_ sender: Any) {
        tempProducts.append(newProductEntry.text!)
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
        return tempProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "productListCell")

        let productName = tempProducts[indexPath.row]
        
        cell.detailTextLabel?.textColor = UIColor.gray
        cell.detailTextLabel?.text = "category"
        
        cell.textLabel?.text = productName
        cell.textLabel?.font = UIFont(name: "American Typewriter", size: 18)
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
}

