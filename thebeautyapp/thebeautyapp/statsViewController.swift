//
//  statsViewController.swift
//  thebeautyapp
//
//  Created by Mikalangelo Wessel on 6/3/18.
//  Copyright © 2018 giraffeflight. All rights reserved.
//

import UIKit
import os.log
import Firebase

var selectedDate: String = ""

class statsViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate {
    
//    static var sharedStatsInstance = statsViewController()
    
    fileprivate weak var calendar: FSCalendar!
    @IBOutlet weak var statsProductList: UITableView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var statsEmptyImageView: UIImageView!
    
    let selection = UISelectionFeedbackGenerator()
    
    
    let green:UIColor = UIColor(red: 0.251, green: 0.831, blue: 0.494, alpha: 1)
    
    var products = [Product]()
    
    var usedProducts = [Product]()
    var daysUsedActivities = [UsedActivity]()
    var ratings = [Rating]()
    var dayRating: Rating?
    
    var datesWithEvent = [String]()
    
    var todaysDate: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ratingControl.delegate = self
        
        if let savedProds = loadProducts() {
            products += savedProds
        }
        
        getDatesWithEvent()
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        todaysDate = formatter.string(from: date)
        selectedDate = todaysDate
        
        getUsedActivities(date: todaysDate)
        setDayRating()
        
        if(daysUsedActivities.count == 0) {
            statsProductList.isHidden = true
            statsEmptyImageView.isHidden = false
        } else {
            statsProductList.isHidden = false
            statsEmptyImageView.isHidden = true
            statsProductList.tableFooterView = UIView(frame: CGRect.zero)
            
            statsProductList.backgroundColor = UIColor.clear
            statsProductList.separatorStyle = UITableViewCell.SeparatorStyle.none
            
            let calendar = FSCalendar(frame: CGRect(x: 0, y: 0, width: 320, height: 300))
            calendar.dataSource = self as FSCalendarDataSource
            calendar.delegate = self as FSCalendarDelegate
            self.calendar = calendar

            // Do any additional setup after loading the view.
            statsProductList.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        products = []
        
        if let savedProds = loadProducts() {
            products += savedProds
        }
        
        getDatesWithEvent()
        getUsedActivities(date: todaysDate)
        setDayRating()
        
        if(daysUsedActivities.count == 0) {
            statsProductList.isHidden = true
            statsEmptyImageView.isHidden = false
        } else {
            statsProductList.isHidden = false
            statsEmptyImageView.isHidden = true
        
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            todaysDate = formatter.string(from: date)
            selectedDate = todaysDate
            
            statsProductList.reloadData()
        }
    }
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    func getDatesWithEvent() {
        for prod in products {
            for datesUsed in prod.usedActivities {
                datesWithEvent.append(datesUsed.date)
            }
        }
    }
    
    func setDayRating() {
        ratings.removeAll()
        if let savedRatings = loadRatings() {
            ratings += savedRatings
        }
        
        var curRating = false
        for rating in ratings {
            if(selectedDate == rating.date) {
                ratingControl.rating = rating.rating
                curRating = true
            }
        }
        
        if(!curRating) {
            ratingControl.rating = 0
        }
    }
    
    func getUsedActivities(date: String) {
        selectedDate = date
        daysUsedActivities.removeAll()
        
        for prod in products {
            for datesUsed in prod.usedActivities {
                if(date == datesUsed.date) {
                    daysUsedActivities.append(datesUsed)
                }
            }
        }
        
        statsProductList.reloadData()
    }
    
    private func loadProducts() -> [Product]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Product.ArchiveURL.path) as? [Product]
    }
    
    private func loadRatings() -> [Rating]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Rating.ArchiveURL.path) as? [Rating]
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
        selection.selectionChanged()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        selectedDate = formatter.string(from: date)

        getUsedActivities(date: selectedDate)

        setDayRating()
        
        if(daysUsedActivities.count == 0) {
            statsProductList.isHidden = true
            statsEmptyImageView.isHidden = false
        } else {
            statsProductList.isHidden = false
            statsEmptyImageView.isHidden = true
        }
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

extension statsViewController: UITableViewDelegate, UITableViewDataSource, RatingViewDelegate {
    
    func setSelectedRating(rating: Int) {
        saveRating(rating: rating, date: selectedDate)
    }
    
    private func saveRating(rating: Int, date: String) {
        print("Saving rating")
        print(date)
        print(rating)
        guard !date.isEmpty else {
            return
        }
        
        // The rating must be between 0 and 5 inclusively
        guard (rating >= 0) && (rating <= 5) else {
            return
        }
        
        var setRating = false
        
        ratings.removeAll()
        
        if let savedRatings = loadRatings() {
            ratings += savedRatings
        }
        
        for rate in ratings {
            if(rate.date == date) {
                Analytics.logEvent("rating_changed", parameters: [
                    "before_rating": rate.rating as NSObject,
                    "after_rating": rating as NSObject
                    ])
                rate.rating = rating
                setRating = true
            }
        }
        
        if(!setRating) {
            Analytics.logEvent("set_rating", parameters: [
                "rating": rating as NSObject
                ])
            dayRating = Rating(date: date, rating: rating)
            ratings.append(dayRating!)
        }
        
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(ratings, toFile: Rating.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Ratings successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save Ratings...", log: OSLog.default, type: .error)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return daysUsedActivities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "statsProductCell")

        let productName = daysUsedActivities[indexPath.row].productName
        let timeOfDay = daysUsedActivities[indexPath.row].ampm
        let timeStamp = daysUsedActivities[indexPath.row].time
    
        var image : UIImage = UIImage(named: "sun-moon-icon.png")!
        if(timeOfDay == 1) {
            image = UIImage(named: "sun-icon.png")!
        } else if(timeOfDay == 2) {
            image = UIImage(named: "moon-icon.png")!
        }
        
        cell.imageView?.image = image
        
        if #available(iOS 13.0, *) {
            cell.detailTextLabel?.textColor = .secondaryLabel
        } else {
            // Fallback on earlier versions
            cell.detailTextLabel?.textColor = UIColor.lightGray
        }
        
        cell.detailTextLabel?.text = timeStamp
        
        var imageView : UIImageView
        imageView  = UIImageView(frame:CGRect(x: 5, y: 5, width: 25, height: 25))
        imageView.image = UIImage(named:"checkmark")
        
        cell.accessoryView = imageView
        
        cell.textLabel?.text = productName
        cell.textLabel?.font = UIFont(name: "System", size: 16)
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
}
