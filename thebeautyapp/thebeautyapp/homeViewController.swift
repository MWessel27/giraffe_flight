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
    @IBOutlet weak var pmTableView: UITableView!
    
    var products = [String]()
    
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
        
        products = ["Lotion","Moisturizer","Lipstick","Exfoliant"]
        mTableView.tableFooterView = UIView(frame: CGRect.zero)
        pmTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        let rightBarButton = UIBarButtonItem(title: "PRODUCTS", style: UIBarButtonItemStyle.plain, target: self, action: #selector(goToProdList))
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        let leftBarButton = UIBarButtonItem(title: "STATS", style: UIBarButtonItemStyle.plain, target: self, action: #selector(goToStatsCal))
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        mTableView.backgroundColor = UIColor.clear
        mTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        pmTableView.backgroundColor = UIColor.clear
        pmTableView.separatorStyle = UITableViewCellSeparatorStyle.none
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
        cell.textLabel?.font = UIFont(name: "American Typewriter", size: 22)
        cell.backgroundColor = UIColor.clear
        
        var imageView : UIImageView
        imageView  = UIImageView(frame:CGRect(x: 5, y: 5, width: 25, height: 25))
        imageView.image = UIImage(named:"checkmarkempty")
        
        cell.accessoryView = imageView

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let date = Date()
        
        let mySelectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        
        if(mySelectedCell.backgroundColor == green){
            mySelectedCell.detailTextLabel?.backgroundColor = UIColor.clear
        } else {
            mySelectedCell.detailTextLabel?.backgroundColor = green
        }
        
        mySelectedCell.detailTextLabel?.font = UIFont(name: "American Typewriter", size: 14)
        
        mySelectedCell.detailTextLabel?.textColor = UIColor.white
        mySelectedCell.detailTextLabel?.text = dateFormatter.string(for: date)
        
        var imageView : UIImageView
        imageView  = UIImageView(frame:CGRect(x: 5, y: 5, width: 25, height: 25))
        imageView.image = UIImage(named:"checkmark")
        
        mySelectedCell.accessoryView = imageView
        
        
        mySelectedCell.tintColor = UIColor.white
        mySelectedCell.backgroundColor = green
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let myHighlightedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        if(myHighlightedCell.backgroundColor == green){
            myHighlightedCell.detailTextLabel?.backgroundColor = UIColor.clear
        } else {
            myHighlightedCell.detailTextLabel?.backgroundColor = green
        }
    }
    
}

