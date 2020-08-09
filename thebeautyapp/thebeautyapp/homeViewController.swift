//
//  ViewController.swift
//  thebeautyapp
//
//  Created by Mikalangelo Wessel on 5/21/18.
//  Copyright © 2018 giraffeflight. All rights reserved.
//

import UIKit
import CoreData
import os.log
import Firebase

class homeViewController: UIViewController, addEditProduct {
    
    private let notificationsImageView = UIImageView(image: UIImage(named: "notifications-icon"))
    private var ratingImageView = UIImageView(image: UIImage(named: "emptyStar"))
    private let ratingStreakLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 75.0, height: 30.0))
    
    @IBOutlet weak var addIconImageView: UIImageView!
    @IBOutlet weak var noProductIcon: UIImageView!
    
    @IBOutlet var homeBackgroundView: UIView!
    
    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet weak var pmTableView: UITableView!
    
    @IBOutlet weak var dayIcon: UIImageView!
    @IBOutlet weak var nightIcon: UIImageView!
    
    @IBOutlet weak var progressBarView: UIView!
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var nightLabel: UILabel!
    
    @IBOutlet weak var dayProductEditButton: UIButton!
    @IBOutlet weak var nightProductEditButton: UIButton!
    
    @IBOutlet weak var cellSelectionIcon: UIImageView!
    @IBOutlet weak var cellLabel: UILabel!
    
    @IBOutlet weak var morningProgressView: UIView!
    @IBOutlet weak var eveningProgressView: UIView!
    
    var progressLyrMorning = CAShapeLayer()
    var trackLyrMorning = CAShapeLayer()
    @IBOutlet weak var morningProgressPercentageLabel: UILabel!
    
    var progressLyrEvening = CAShapeLayer()
    var trackLyrEvening = CAShapeLayer()
    @IBOutlet weak var eveningProgressPercentageLabel: UILabel!
    
    let selection = UISelectionFeedbackGenerator()
    
    var products = [Product]()
    var currentStreak = [Streak]()
    
    var ratings = [Rating]()
    var dayRating: Rating?
    
    var todaysDate: String = ""
    var yesterdaysDate: String = ""
    
    var dayOfWeek = 0
    var morningProgressIndicatorCount = 0
    var morningProductCount = 0
    var morningProgressPercentage: Float = 0.0
    
    var eveningProgressIndicatorCount = 0
    var eveningProductCount = 0
    var eveningProgressPercentage: Float = 0.0
    
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
//        let tappedImage = tapGestureRecognizer.view as! UIImageView

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
    
    @objc func ratingIconImageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
//        let tappedImage = tapGestureRecognizer.view as! UIImageView

        guard let ratingVC = storyboard?.instantiateViewController(withIdentifier: "RatingViewController")
        as? RatingViewController else {
            assertionFailure("No view controller ID RatingViewController in storyboard")
            return
        }
        
        // Delay the capture of snapshot by 0.1 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 , execute: {
          // take a snapshot of current view and set it as backingImage
          ratingVC.backingImage = self.tabBarController?.view.asImage()
          
          // present the view controller modally without animation
          self.present(ratingVC, animated: false, completion: nil)
        })
    }
    
    func showRatingViewController() {
        guard let ratingVC = storyboard?.instantiateViewController(withIdentifier: "RatingViewController")
        as? RatingViewController else {
            assertionFailure("No view controller ID RatingViewController in storyboard")
            return
        }
        
        // Delay the capture of snapshot by 0.1 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 , execute: {
          // take a snapshot of current view and set it as backingImage
          ratingVC.backingImage = self.tabBarController?.view.asImage()
          
          // present the view controller modally without animation
          self.present(ratingVC, animated: false, completion: nil)
        })
    }
    
    @objc func addIconImageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
//        let tappedImage = tapGestureRecognizer.view as! UIImageView

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

    var progressClrMorning = UIColor.white {
       didSet {
          progressLyrMorning.strokeColor = progressClrMorning.cgColor
       }
    }
    var trackClrMorning = UIColor.white {
       didSet {
          trackLyrMorning.strokeColor = trackClrMorning.cgColor
       }
    }
    
    var progressClrEvening = UIColor.white {
       didSet {
          progressLyrEvening.strokeColor = progressClrEvening.cgColor
       }
    }
    var trackClrEvening = UIColor.white {
       didSet {
          trackLyrEvening.strokeColor = trackClrEvening.cgColor
       }
    }
    
    func makeCircularPathMorning(progressView: UIView) {
        progressLyrMorning.lineCap = .round
        progressView.backgroundColor = UIColor.clear
        progressView.layer.cornerRadius = progressView.frame.size.width/2
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: progressView.frame.size.width/2, y: progressView.frame.size.height/2), radius: (progressView.frame.size.width - 15)/2, startAngle: CGFloat(-0.5 * .pi), endAngle: CGFloat(1.5 * .pi), clockwise: true)
        trackLyrMorning.path = circlePath.cgPath
        trackLyrMorning.fillColor = UIColor.clear.cgColor
        trackLyrMorning.strokeColor = trackClrMorning.cgColor
        trackLyrMorning.lineWidth = 12
        trackLyrMorning.strokeEnd = 1.0
        progressView.layer.addSublayer(trackLyrMorning)
        progressLyrMorning.path = circlePath.cgPath
        progressLyrMorning.fillColor = UIColor.clear.cgColor
        progressLyrMorning.strokeColor = progressClrMorning.cgColor
        progressLyrMorning.lineWidth = 14.5
        progressLyrMorning.strokeEnd = 0.0
        progressView.layer.addSublayer(progressLyrMorning)
    }
    
    func makeCircularPathEvening(progressView: UIView) {
        progressLyrEvening.lineCap = .round
        progressView.backgroundColor = UIColor.clear
        progressView.layer.cornerRadius = progressView.frame.size.width/2
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: progressView.frame.size.width/2, y: progressView.frame.size.height/2), radius: (progressView.frame.size.width - 15)/2, startAngle: CGFloat(-0.5 * .pi), endAngle: CGFloat(1.5 * .pi), clockwise: true)
        trackLyrEvening.path = circlePath.cgPath
        trackLyrEvening.fillColor = UIColor.clear.cgColor
        trackLyrEvening.strokeColor = trackClrEvening.cgColor
        trackLyrEvening.lineWidth = 12
        trackLyrEvening.strokeEnd = 1.0
        progressView.layer.addSublayer(trackLyrEvening)
        progressLyrEvening.path = circlePath.cgPath
        progressLyrEvening.fillColor = UIColor.clear.cgColor
        progressLyrEvening.strokeColor = progressClrEvening.cgColor
        progressLyrEvening.lineWidth = 14.5
        progressLyrEvening.strokeEnd = 0.0
        progressView.layer.addSublayer(progressLyrEvening)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        morningProgressIndicatorCount = 0
        morningProductCount = 0
        
        eveningProgressIndicatorCount = 0
        eveningProductCount = 0
        
        morningProgressView.isHidden = true
        morningProgressPercentageLabel.isHidden = true
        eveningProgressView.isHidden = true
        eveningProgressPercentageLabel.isHidden = true
        
        if #available(iOS 13.0, *) {
            trackClrMorning = UIColor.systemBackground
            progressClrMorning = UIColor.label
            
            trackClrEvening = UIColor.systemBackground
            progressClrEvening = UIColor.label
        } else {
            // Fallback on earlier versions
            trackClrMorning = UIColor.white
            progressClrMorning = UIColor.black
            
            trackClrEvening = UIColor.white
            progressClrEvening = UIColor.black
        }
    
        setupUI()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        notificationsImageView.isUserInteractionEnabled = true
        notificationsImageView.addGestureRecognizer(tapGestureRecognizer)
        
        let addGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addIconImageTapped(tapGestureRecognizer:)))
//        let streakGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ratingIconImageTapped(tapGestureRecognizer:)))
        addIconImageView.isUserInteractionEnabled = true
        addIconImageView.addGestureRecognizer(addGestureRecognizer)
//        ratingStreakLabel.isUserInteractionEnabled = true
//        ratingStreakLabel.addGestureRecognizer(streakGestureRecognizer)
        
        let ratingGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ratingIconImageTapped(tapGestureRecognizer:)))
        ratingImageView.isUserInteractionEnabled = true
        ratingImageView.addGestureRecognizer(ratingGestureRecognizer)
        
        
        // returns an integer from 1 - 7, with 1 being Sunday and 7 being Saturday
        dayOfWeek = Date().dayNumberOfWeek()!
        
        if let savedProds = loadProducts() {
            products += savedProds
        }
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        todaysDate = formatter.string(from: date)
        yesterdaysDate = formatter.string(from: Date.yesterday)
        
        setStreak()
        
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
    
    func setMorningProgressBar(percentage: Float) {
        let percentageInt = Int(round((Float(morningProgressIndicatorCount)/Float(morningProductCount))*100))
        makeCircularPathMorning(progressView: morningProgressView)
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 1.5
        animation.fromValue = morningProgressPercentage
        animation.toValue = percentage
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        progressLyrMorning.strokeEnd = CGFloat(percentage)
        progressLyrMorning.add(animation, forKey: "animateprogress")

        morningProgressPercentage = percentage
        
        morningProgressPercentageLabel.text = String(percentageInt) + "%"
    }
    
    func setEveningProgressBar(percentage: Float) {
        let percentageInt = Int(round((Float(eveningProgressIndicatorCount)/Float(eveningProductCount))*100))
        makeCircularPathEvening(progressView: eveningProgressView)
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 1.5
        animation.fromValue = eveningProgressPercentage
        animation.toValue = percentage
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        progressLyrEvening.strokeEnd = CGFloat(percentage)
        progressLyrEvening.add(animation, forKey: "animateprogress")

        eveningProgressPercentage = percentage
        
        eveningProgressPercentageLabel.text = String(percentageInt) + "%"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        morningProgressIndicatorCount = 0
        morningProductCount = 0
        
        morningProgressView.isHidden = true
        morningProgressPercentageLabel.isHidden = true
        
        eveningProgressIndicatorCount = 0
        eveningProductCount = 0
        
        eveningProgressView.isHidden = true
        eveningProgressPercentageLabel.isHidden = true
        
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
            
            morningProgressView.isHidden = true
            morningProgressPercentageLabel.isHidden = true
            
            eveningProgressView.isHidden = true
            eveningProgressPercentageLabel.isHidden = true

            mTableView.isHidden = true;
            pmTableView.isHidden = true;
        }
        
        self.mTableView.reloadData();
        self.pmTableView.reloadData();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        setStreak()
        
        morningProgressIndicatorCount = 0
        morningProductCount = 0
        
        morningProgressView.isHidden = true
        morningProgressPercentageLabel.isHidden = true
        
        eveningProgressIndicatorCount = 0
        eveningProductCount = 0
        
        eveningProgressView.isHidden = true
        eveningProgressPercentageLabel.isHidden = true
        
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
            
            morningProgressView.isHidden = true
            morningProgressPercentageLabel.isHidden = true
            
            eveningProgressView.isHidden = true
            eveningProgressPercentageLabel.isHidden = true

            mTableView.isHidden = true;
            pmTableView.isHidden = true;
        }
        
        self.mTableView.reloadData();
        self.pmTableView.reloadData();
    }
    
    private func loadProducts() -> [Product]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Product.ArchiveURL.path) as? [Product]
    }
    
    private func loadStreak() -> [Streak]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Streak.ArchiveURL.path) as? [Streak]
    }
    
    private func loadRatings() -> [Rating]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Rating.ArchiveURL.path) as? [Rating]
    }
    
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        
        title = "Today"
        
        let dateFormatter = DateFormatter()
        // uncomment to enforce the US locale
        // dateFormatter.locale = Locale(identifier: "en-US")
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEE MMMM d")

        // Initial setup for image for Large NavBar state since the the screen always has Large NavBar once it gets opened
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        navigationBar.addSubview(setTitle(title: "Today", subtitle: dateFormatter.string(from: Date()).uppercased()))
        navigationBar.addSubview(notificationsImageView)
        notificationsImageView.layer.cornerRadius = Const.ImageSizeForLargeState / 2
        notificationsImageView.clipsToBounds = true
        notificationsImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            notificationsImageView.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -Const.ImageRightMargin),
            notificationsImageView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -Const.ImageBottomMarginForLargeState),
            notificationsImageView.heightAnchor.constraint(equalToConstant: Const.ImageSizeForLargeState),
            notificationsImageView.widthAnchor.constraint(equalTo: notificationsImageView.heightAnchor)
            ])
        
        navigationBar.addSubview(ratingImageView)
        ratingImageView.layer.cornerRadius = Const.ImageSizeForLargeState / 2
        ratingImageView.clipsToBounds = true
        ratingImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            ratingImageView.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -Const.ImageRightMargin*5),
            ratingImageView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -Const.ImageBottomMarginForLargeState),
            ratingImageView.heightAnchor.constraint(equalToConstant: Const.ImageSizeForLargeState),
            ratingImageView.widthAnchor.constraint(equalTo: ratingImageView.heightAnchor)
            ])
        
        navigationBar.addSubview(ratingStreakLabel)
//        ratingStreakLabel.text = "35"
        ratingStreakLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            ratingStreakLabel.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -Const.ImageRightMargin*2.75),
            ratingStreakLabel.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -Const.ImageBottomMarginForLargeState),
            ratingStreakLabel.heightAnchor.constraint(equalToConstant: Const.ImageSizeForLargeState),
            ratingStreakLabel.widthAnchor.constraint(equalTo: ratingImageView.heightAnchor)
            ])
    }
    
    func setTitle(title:String, subtitle:String) -> UIView {

        //Get navigation Bar Height and Width
        let navigationBarHeight = Int(self.navigationController!.navigationBar.frame.height)
        let navigationBarWidth = Int(self.navigationController!.navigationBar.frame.width)

        //Y position for Title and Subtitle
        let y_Title = 48.0
        let y_SubTitle = 16.0

        //Set Font size and weight for Title and Subtitle
        let titleFont = UIFont.systemFont(ofSize: 33, weight: UIFont.Weight.bold)
        let subTitleFont = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.semibold)

        //SubTitle label
        let subtitleLabel = UILabel(frame: CGRect(x: 20, y: y_SubTitle, width: 0, height: 0))
        subtitleLabel.backgroundColor = UIColor.clear
        subtitleLabel.textColor = UIColor.gray
        subtitleLabel.font = subTitleFont
        subtitleLabel.text = subtitle
        subtitleLabel.sizeToFit()

        //Add Title and Subtitle to View
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: navigationBarWidth, height: navigationBarHeight))
        titleView.addSubview(subtitleLabel)

        return titleView

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
    
    static func requireUserAttention(on onView: UIImageView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: onView.center.x - 3, y: onView.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: onView.center.x + 3, y: onView.center.y))
        onView.layer.add(animation, forKey: "position")
    }
    
    func getNotificationStatus() -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: "ReminderSwitchState")
    }
    
    //MARK: Rating Streak
    func setStreak() {
        ratings.removeAll()
        if let savedRatings = loadRatings() {
            ratings += savedRatings
        }
        
        if let todaysStreak = loadStreak() {
            currentStreak = todaysStreak
        }
        
        var ratingYesterday = false
        if(!currentStreak.isEmpty) {
            currentStreak[0].setToday = false
            for rating in ratings {
                if(todaysDate == rating.date && rating.rating > 0) {
                    currentStreak[0].setToday = true
                }
                if(yesterdaysDate == rating.date && rating.rating > 0) {
                    ratingYesterday = true
                }
            }
        }
        
        // current streak logic
        if(currentStreak.isEmpty) {
            // set empty star and zero. Save streak for a baseline
            showSaveStreak(icon: false, streak: 0)
        } else if(!currentStreak.isEmpty && !ratingYesterday && !currentStreak[0].setToday) {
            //set empty star and zero out streak since its not empty
            showSaveStreak(icon: false, streak: 0)
        } else if(!currentStreak.isEmpty && !ratingYesterday && currentStreak[0].setToday) {
            //set gold star and streak to 1 since its set today but not yesterdays
            showSaveStreak(icon: true, streak: 1)
        } else if(!currentStreak.isEmpty && ratingYesterday && !currentStreak[0].setToday) {
            // rating yesterday, rating not set today
            // set empty star with streak label
            if(currentStreak[0].streak != 0) {
                showSaveStreak(icon: false, streak: currentStreak[0].streak)
            } else {
                showSaveStreak(icon: false, streak: 1)
            }
        } else if(!currentStreak.isEmpty && ratingYesterday && currentStreak[0].setToday) {
            // rating yesterday and today
            // set gold star with current streak number
            showSaveStreak(icon: true, streak: currentStreak[0].streak)
        } else {
            // gold star with streak # incremented
            showSaveStreak(icon: true, streak: currentStreak[0].streak + 1)
        }
    }
    
    func showSaveStreak(icon: Bool, streak: Int) {
        if(currentStreak.isEmpty) {
            let tempStreak = Streak(setToday: icon, streak: streak)
            currentStreak.append(tempStreak!)
        } else {
            currentStreak[0].setToday = icon
            currentStreak[0].streak = streak
        }
        if(currentStreak[0].streak >= 2) {
            Analytics.logEvent("request_review_attempt", parameters: [
            "dateRequested": todaysDate as NSObject
            ])
            AppStoreReviewManager.requestReviewIfAppropriate()
        }
        saveStreak()
        if(getNotificationStatus()) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "scheduleStreakNotification"), object: nil)
        }
        if(icon && streak > 0) {
            ratingImageView.image = UIImage(named: "goldStar")
            ratingStreakLabel.text = String(streak)
            if #available(iOS 13.0, *) {
                ratingStreakLabel.textColor = UIColor.label
            } else {
                ratingStreakLabel.textColor = UIColor.black
            }
        } else {
            ratingImageView.image = UIImage(named: "emptyStar")
            ratingStreakLabel.text = String(streak)
            ratingStreakLabel.textColor = .systemGray
        }
    }
    
    private func saveStreak() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(currentStreak, toFile: Streak.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Streak successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save streak...", log: OSLog.default, type: .error)
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
                morningProductCount += 1
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
                    cell.productDetailTextLabel?.font = UIFont(name: "System", size: 8)
                    cell.productDetailTextLabel?.textColor = UIColor.gray
                    cell.productDetailTextLabel?.text = timeStamp
                    
                    cell.tintColor = UIColor.white
                    cell.backgroundColor = UIColor.clear
                    
                    cell.cellSelectedImage.image = UIImage(named: "checkmark.png")!
                    morningProgressIndicatorCount += 1
                } else {
                    cell.cellLabel.font = UIFont(name: "System", size: 24)
                    cell.cellLabel.backgroundColor = UIColor.clear
                    cell.productDetailTextLabel?.backgroundColor = UIColor.clear
                    cell.productDetailTextLabel?.text = ""
                    cell.cellSelectedImage.image = UIImage(named: "checkmarkempty.png")!
                }
                
                if(morningProgressIndicatorCount > 0) {
                    morningProgressView.isHidden = false
                    morningProgressPercentageLabel.isHidden = false
                    dayIcon.isHidden = true
                }
                
                setMorningProgressBar(percentage: (Float(morningProgressIndicatorCount)/Float(morningProductCount)))
                
                return cell
            } else {
                cell.isHidden = true
            }
        } else {
            if((products[indexPath.row].ampm == 2 || products[indexPath.row].ampm == 0)  && productValidForDay) {
                
                var checked = false
                var timeStamp = ""
                eveningProductCount += 1
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
                    cell.productDetailTextLabel?.font = UIFont(name: "System", size: 8)
                    cell.productDetailTextLabel?.textColor = UIColor.gray
                    cell.productDetailTextLabel?.text = timeStamp
                    
                    cell.tintColor = UIColor.white
                    cell.backgroundColor = UIColor.clear
                    
                    cell.cellSelectedImage.image = UIImage(named: "checkmark.png")!
                    eveningProgressIndicatorCount += 1
                } else {
                    cell.cellLabel.font = UIFont(name: "System", size: 24)
                    cell.cellLabel.backgroundColor = UIColor.clear
                    cell.productDetailTextLabel?.backgroundColor = UIColor.clear
                    cell.productDetailTextLabel?.text = ""
                    cell.cellSelectedImage.image = UIImage(named: "checkmarkempty.png")!
                }
                
                if(eveningProgressIndicatorCount > 0) {
                    eveningProgressView.isHidden = false
                    eveningProgressPercentageLabel.isHidden = false
                    nightIcon.isHidden = true
                }
                
                setEveningProgressBar(percentage: (Float(eveningProgressIndicatorCount)/Float(eveningProductCount)))
                
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
        selection.selectionChanged()
        
        
        if(!getNotificationStatus()) {
            homeViewController.requireUserAttention(on: notificationsImageView)
        }
        
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
            if(tableView == mTableView) {
                morningProgressIndicatorCount -= 1
            } else {
                eveningProgressIndicatorCount -= 1
            }
        } else {
            addUsedActivity(product: products[indexPath.row], ampm: ampm)
            mySelectedCell.cellLabel.font = UIFont(name: "System", size: 24)
            mySelectedCell.productDetailTextLabel?.backgroundColor = UIColor.clear
            mySelectedCell.productDetailTextLabel?.font = UIFont(name: "System", size: 8)
            mySelectedCell.productDetailTextLabel?.textColor = UIColor.gray
            
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            let currentTime = formatter.string(for: date)
            mySelectedCell.productDetailTextLabel?.text = currentTime
            
            mySelectedCell.cellSelectedImage.image = UIImage(named: "checkmark.png")!
            mySelectedCell.tintColor = UIColor.white
            mySelectedCell.backgroundColor = UIColor.clear
            if(tableView == mTableView) {
                morningProgressIndicatorCount += 1
            } else {
                eveningProgressIndicatorCount += 1
            }
        }
        
        if(morningProgressIndicatorCount > 0) {
            morningProgressView.isHidden = false
            morningProgressPercentageLabel.isHidden = false
            dayIcon.isHidden = true
        }
        
        if(eveningProgressIndicatorCount > 0) {
            eveningProgressView.isHidden = false
            eveningProgressPercentageLabel.isHidden = false
            nightIcon.isHidden = true
        }
        
        if((morningProgressIndicatorCount == morningProductCount || eveningProgressIndicatorCount == eveningProductCount) && !currentStreak[0].setToday) {
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (nil) in
                self.showRatingViewController()
            }
        }
        
        setMorningProgressBar(percentage: (Float(morningProgressIndicatorCount)/Float(morningProductCount)))
        setEveningProgressBar(percentage: (Float(eveningProgressIndicatorCount)/Float(eveningProductCount)))
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
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow:  Date { return Date().dayAfter }
    static var dayAfterTomorrow: Date { return Date().twoDaysFromNow }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    }
    var twoDaysFromNow: Date {
        return Calendar.current.date(byAdding: .day, value: 2, to: Date())!
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
