//
//  ViewController.swift
//  thebeautyapp
//
//  Created by Mikalangelo Wessel on 5/21/18.
//  Copyright © 2018 giraffeflight. All rights reserved.
//

import UIKit

class homeViewController: UIViewController {
    
    @IBOutlet weak var mTableView: UITableView!
    
    var products = [String]()
    
    let lightOrange:UIColor = UIColor(red: 0.996, green: 0.467, blue: 0.224, alpha: 1)
    let medOrange:UIColor = UIColor(red: 0.973, green: 0.388, blue: 0.173, alpha: 1)
    let darkOrange:UIColor = UIColor(red: 0.796, green: 0.263, blue: 0.106, alpha: 1)
    
    let green:UIColor = UIColor(red: 0.251, green: 0.831, blue: 0.494, alpha: 1)
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        products = ["Lotion","Moisturizer","Lipstick"]
        mTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        let rightBarButton = UIBarButtonItem(title: "Products", style: UIBarButtonItemStyle.plain, target: self, action: #selector(goToProdList))
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        let leftBarButton = UIBarButtonItem(title: "Stats", style: UIBarButtonItemStyle.plain, target: self, action: #selector(goToStatsCal))
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        mTableView.backgroundColor = darkOrange
        mTableView.separatorStyle = UITableViewCellSeparatorStyle.none
    }
    
    @objc func goToProdList() {
        let storyBoard : UIStoryboard = self.storyboard!
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "productViewController")
        self.navigationController?.pushViewController(nextViewController, animated: true)
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "ProductCell")
        let productName = products[indexPath.row]
        cell.textLabel?.text = productName
        cell.backgroundColor = medOrange
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.textColor = UIColor.gray
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let date = Date()
        
        
        let mySelectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        mySelectedCell.detailTextLabel?.textColor = UIColor.white
        mySelectedCell.detailTextLabel?.text = dateFormatter.string(for: date)
        mySelectedCell.accessoryType = UITableViewCellAccessoryType.checkmark
        mySelectedCell.tintColor = UIColor.white
        mySelectedCell.detailTextLabel?.backgroundColor = green
        mySelectedCell.backgroundColor = green
    }
    
}

