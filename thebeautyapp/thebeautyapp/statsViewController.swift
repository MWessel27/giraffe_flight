//
//  statsViewController.swift
//  thebeautyapp
//
//  Created by Mikalangelo Wessel on 6/3/18.
//  Copyright © 2018 giraffeflight. All rights reserved.
//

import UIKit

class statsViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate {
    
    fileprivate weak var calendar: FSCalendar!
    @IBOutlet weak var statsProductList: UITableView!
    
    let green:UIColor = UIColor(red: 0.251, green: 0.831, blue: 0.494, alpha: 1)
    
    var products = [Product]()
    
    var usedProducts = [Product]()
    
    var datesWithEvent = [String]()
    
    var todaysDate: String = ""
    var selectedDate: String = ""
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    let dateFormatterGet = DateFormatter()
    
    func getDatesWithEvent() {
        for prod in products {
            for datesUsed in prod.usedActivities {
                datesWithEvent.append(datesUsed.date)
            }
        }
    }
    
    func getSelectedDaysProducts(date: String) {
        
        selectedDate = date
        
        usedProducts.removeAll()
        
        for prod in products {
            for datesUsed in prod.usedActivities {
                if(date == datesUsed.date) {
                    usedProducts.append(prod)
                }
            }
        }
        
        statsProductList.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let savedProds = loadProducts() {
            products += savedProds
        }
        
        getDatesWithEvent()
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        todaysDate = formatter.string(from: date)
        selectedDate = todaysDate
        
        getSelectedDaysProducts(date: todaysDate)
        
        statsProductList.tableFooterView = UIView(frame: CGRect.zero)
        
        statsProductList.backgroundColor = UIColor.clear
        statsProductList.separatorStyle = UITableViewCellSeparatorStyle.none
        
        let calendar = FSCalendar(frame: CGRect(x: 0, y: 0, width: 320, height: 300))
        calendar.dataSource = self as FSCalendarDataSource
        calendar.delegate = self as FSCalendarDelegate
        self.calendar = calendar

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        getSelectedDaysProducts(date: selectedDate)

        statsProductList.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);

        getSelectedDaysProducts(date: selectedDate)
        
        statsProductList.reloadData()
    }
    
    private func loadProducts() -> [Product]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Product.ArchiveURL.path) as? [Product]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateString = self.dateFormatter.string(from: date)
        if self.datesWithEvent.contains(dateString) {
            return 1
        }
        return 0
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let selectedDate = formatter.string(from: date)
        
        getSelectedDaysProducts(date: selectedDate)
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

extension statsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "statsProductCell")
        
        var timeOfDay = 0
        if(!(indexPath.row > usedProducts.count - 1)) {
            let productName = usedProducts[indexPath.row].name
            
            for usedActivity in usedProducts[indexPath.row].usedActivities {
                if(selectedDate == usedActivity.date) {
                    timeOfDay = usedActivity.ampm
                }
            }
            
            var image : UIImage = UIImage(named: "sunMoonIcon.png")!
            if(timeOfDay == 1) {
                image = UIImage(named: "sunIconSmall.png")!
            } else if(timeOfDay == 2) {
                image = UIImage(named: "moonIconSmall.png")!
            }
            
            cell.imageView?.image = image
            let date = Date()
            dateFormatterGet.dateFormat = "h:mm a"
            
            cell.detailTextLabel?.textColor = UIColor.gray
            cell.detailTextLabel?.text = dateFormatterGet.string(for: date)
            
            var imageView : UIImageView
            imageView  = UIImageView(frame:CGRect(x: 5, y: 5, width: 25, height: 25))
            imageView.image = UIImage(named:"checkmark")
            
            cell.accessoryView = imageView
            
            cell.textLabel?.text = productName
            cell.textLabel?.font = UIFont(name: "American Typewriter", size: 16)
            cell.backgroundColor = UIColor.clear
        }
        
        return cell
    }
}
