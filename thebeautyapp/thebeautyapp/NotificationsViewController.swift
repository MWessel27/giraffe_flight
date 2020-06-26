//
//  NotificationsViewController.swift
//  Flawless
//
//  Created by Mikalangelo Wessel on 5/24/20.
//  Copyright © 2020 giraffeflight. All rights reserved.
//

import UIKit
import CoreData
import os.log
import Firebase
import UserNotifications

class NotificationsViewController: UIViewController {
    
    @IBOutlet weak var backingImageView: UIImageView!
    @IBOutlet weak var dimmerView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var handleView: UIView!
    
    @IBOutlet weak var cardViewTopConstraints: NSLayoutConstraint!
    
    // Reminder outlets
    @IBOutlet weak var reminderSwitch: UISwitch!
    @IBOutlet weak var reminderView: UIView!
    @IBOutlet weak var reminderTimePicker: UIDatePicker!
    
    enum CardViewState {
        case expanded
        case normal
    }
    
    // default card view state is normal
    var cardViewState : CardViewState = .normal

    // to store the card view top constraint value before the dragging start
    // default is 30 pt from safe area top
    var cardPanStartingTopConstant : CGFloat = 30.0
    
    // to store backing (snapshot) image
    var backingImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }

        // update the backing image view
        backingImageView.image = backingImage
        
        // round the top left and top right corner of card view
        cardView.clipsToBounds = true
        cardView.layer.cornerRadius = 10.0
        cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        // hide the card view at the bottom when the View first load
        if let safeAreaHeight = UIApplication.shared.keyWindow?.safeAreaLayoutGuide.layoutFrame.size.height,
          let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom {
          cardViewTopConstraints.constant = safeAreaHeight + bottomPadding
        }
        
        // set dimmerview to transparent
        dimmerView.alpha = 0.0
        
        // dimmerViewTapped() will be called when user tap on the dimmer view
        let dimmerTap = UITapGestureRecognizer(target: self, action: #selector(dimmerViewTapped(_:)))
        dimmerView.addGestureRecognizer(dimmerTap)
        dimmerView.isUserInteractionEnabled = true
        
        // add pan gesture recognizer to the view controller's view (the whole screen)
        let viewPan = UIPanGestureRecognizer(target: self, action: #selector(viewPanned(_:)))
        
        // by default iOS will delay the touch before recording the drag/pan information
        // we want the drag gesture to be recorded down immediately, hence setting no delay
        viewPan.delaysTouchesBegan = false
        viewPan.delaysTouchesEnded = false

        self.view.addGestureRecognizer(viewPan)
        
        // round the handle view
        handleView.clipsToBounds = true
        handleView.layer.cornerRadius = 3.0
        
        // Reminder time selector
        let defaults = UserDefaults.standard
            
            if (defaults.object(forKey: "ReminderSwitchState") != nil) {
                reminderSwitch.isOn = defaults.bool(forKey: "ReminderSwitchState")
            }
            
            let center = UNUserNotificationCenter.current()

            center.getPendingNotificationRequests(completionHandler: { requests in
                var nextTriggerDates: [Date] = []
                for request in requests {
                    print(request)
                    if let trigger = request.trigger as? UNCalendarNotificationTrigger,
                        let triggerDate = trigger.nextTriggerDate(){
                        nextTriggerDates.append(triggerDate)
                    }

                    if let nextTriggerDate = nextTriggerDates.min() {
                        print(nextTriggerDate)
                        self.setDateForPicker(pickerDate: nextTriggerDate)
                    }
                }
            })
    }
    
    func setDateForPicker(pickerDate: Date) {
        DispatchQueue.global().async(execute: {
            DispatchQueue.main.sync{
                self.reminderTimePicker.date = pickerDate
            }
        })
    }
    
    func scheduleNotification() {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Skin Care Reminder"
        content.body = "Time to complete your daily skin care routine."
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default
        
        let reminderDate = getDateFromPicker()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH mm"
        let reminderTime = dateFormatter.string(from: reminderDate)

        dateFormatter.dateFormat = "HH"
        let hour = dateFormatter.string(from: reminderDate)
        dateFormatter.dateFormat = "mm"
        let minute = dateFormatter.string(from: reminderDate)
        print(hour)
        print(minute)
        
        var dateComponents = DateComponents()
        dateComponents.hour = Int(hour)!
        dateComponents.minute = Int(minute)!
        
        if(getReminderSwitchState()) {
            Analytics.logEvent("reminder_on", parameters: [
                "time": reminderTime as NSObject
                ])
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
    }
    
    @IBAction func reminderTimePickerChanged(_ sender: Any) {
        if(getReminderSwitchState()) {
            let defaults = UserDefaults.standard
            print(self.reminderTimePicker.date)
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            self.scheduleNotification()
            defaults.set(true, forKey: "ReminderSwitchState")
        }
    }
    
    func getReminderSwitchState() -> Bool {
        var reminderOnOff = false
        
        if(self.reminderSwitch.isOn) {
            reminderOnOff = true
        }
        
        return reminderOnOff
    }
    
    func getDateFromPicker() -> Date {
        var reminderDate = Date()

        reminderDate = self.reminderTimePicker.date
        
        return reminderDate
    }
    
    
    @IBAction func reminderToggle(_ sender: Any) {
        
        let defaults = UserDefaults.standard
        
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Notification Permissions On")
            } else {
                print("Notification Permissions Off")
            }
        }
        
        if reminderSwitch.isOn {
            print("Scheduling notification")
            self.scheduleNotification()
            defaults.set(true, forKey: "ReminderSwitchState")
        } else {
            Analytics.logEvent("reminder_off", parameters: nil)
            print("Cleared notification")
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            defaults.set(false, forKey: "ReminderSwitchState")
        }
    }
    
    @IBAction func viewPanned(_ panRecognizer: UIPanGestureRecognizer) {
      let velocity = panRecognizer.velocity(in: self.view)
      let translation = panRecognizer.translation(in: self.view)
      
      switch panRecognizer.state {
      case .began:
        cardPanStartingTopConstant = cardViewTopConstraints.constant
        
      case .changed:
        if self.cardPanStartingTopConstant + translation.y > 30.0 {
          self.cardViewTopConstraints.constant = self.cardPanStartingTopConstant + translation.y
        }
        
        // change the dimmer view alpha based on how much user has dragged
        dimmerView.alpha = dimAlphaWithCardTopConstraint(value: self.cardViewTopConstraints.constant)

      case .ended:
        if velocity.y > 1500.0 {
          hideCardAndGoBack()
          return
        }
        
        if let safeAreaHeight = UIApplication.shared.keyWindow?.safeAreaLayoutGuide.layoutFrame.size.height,
          let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom {
          
          if self.cardViewTopConstraints.constant < (safeAreaHeight + bottomPadding) * 0.25 {
            showCard(atState: .expanded)
          } else if self.cardViewTopConstraints.constant < (safeAreaHeight) - 70 {
            showCard(atState: .normal)
          } else {
            hideCardAndGoBack()
          }
        }
      default:
        break
      }
    }
    
    // @IBAction is required in front of the function name due to how selector works
    @IBAction func dimmerViewTapped(_ tapRecognizer: UITapGestureRecognizer) {
      hideCardAndGoBack()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        showCard()
        
        let defaults = UserDefaults.standard
        
        if (defaults.object(forKey: "ReminderSwitchState") != nil) {
            reminderSwitch.isOn = defaults.bool(forKey: "ReminderSwitchState")
        }
        
        let center = UNUserNotificationCenter.current()
        
        center.getPendingNotificationRequests(completionHandler: { requests in
            var nextTriggerDates: [Date] = []
            for request in requests {
                print(request)
                if let trigger = request.trigger as? UNCalendarNotificationTrigger,
                    let triggerDate = trigger.nextTriggerDate(){
                    nextTriggerDates.append(triggerDate)
                }
                
                if let nextTriggerDate = nextTriggerDates.min() {
                    print(nextTriggerDate)
                    self.setDateForPicker(pickerDate: nextTriggerDate)
                }
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showCard()
        
        let defaults = UserDefaults.standard
        
        if (defaults.object(forKey: "ReminderSwitchState") != nil) {
            reminderSwitch.isOn = defaults.bool(forKey: "ReminderSwitchState")
        }
        
        let center = UNUserNotificationCenter.current()
        
        center.getPendingNotificationRequests(completionHandler: { requests in
            var nextTriggerDates: [Date] = []
            for request in requests {
                print(request)
                if let trigger = request.trigger as? UNCalendarNotificationTrigger,
                    let triggerDate = trigger.nextTriggerDate(){
                    nextTriggerDates.append(triggerDate)
                }
                
                if let nextTriggerDate = nextTriggerDates.min() {
                    print(nextTriggerDate)
                    self.setDateForPicker(pickerDate: nextTriggerDate)
                }
            }
        })
    }

    // default to show card at normal state, if showCard() is called without parameter
    private func showCard(atState: CardViewState = .normal) {
       
      // ensure there's no pending layout changes before animation runs
      self.view.layoutIfNeeded()
      
      // set the new top constraint value for card view
      // card view won't move up just yet, we need to call layoutIfNeeded()
      // to tell the app to refresh the frame/position of card view
      if let safeAreaHeight = UIApplication.shared.keyWindow?.safeAreaLayoutGuide.layoutFrame.size.height,
        let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom {
        
        if atState == .expanded {
          // if state is expanded, top constraint is 30pt away from safe area top
          cardViewTopConstraints.constant = 60.0
        } else {
          cardViewTopConstraints.constant = (safeAreaHeight + bottomPadding) / 2.0
        }
        
        cardPanStartingTopConstant = cardViewTopConstraints.constant
      }
      
      // move card up from bottom
      // create a new property animator
      let showCard = UIViewPropertyAnimator(duration: 0.25, curve: .easeIn, animations: {
        self.view.layoutIfNeeded()
      })
      
      // show dimmer view
      // this will animate the dimmerView alpha together with the card move up animation
      showCard.addAnimations {
        self.dimmerView.alpha = 0.7
      }
      
      // run the animation
      showCard.startAnimation()
    }
    
    private func hideCardAndGoBack() {
      // ensure there's no pending layout changes before animation runs
      self.view.layoutIfNeeded()
      
      // set the new top constraint value for card view
      // card view won't move down just yet, we need to call layoutIfNeeded()
      // to tell the app to refresh the frame/position of card view
      if let safeAreaHeight = UIApplication.shared.keyWindow?.safeAreaLayoutGuide.layoutFrame.size.height,
        let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom {
        
        // move the card view to bottom of screen
        cardViewTopConstraints.constant = safeAreaHeight + bottomPadding
      }
      
      // move card down to bottom
      // create a new property animator
      let hideCard = UIViewPropertyAnimator(duration: 0.25, curve: .easeIn, animations: {
        self.view.layoutIfNeeded()
      })
      
      // hide dimmer view
      // this will animate the dimmerView alpha together with the card move down animation
      hideCard.addAnimations {
        self.dimmerView.alpha = 0.0
      }
      
      // when the animation completes, (position == .end means the animation has ended)
      // dismiss this view controller (if there is a presenting view controller)
      hideCard.addCompletion({ position in
        if position == .end {
          if(self.presentingViewController != nil) {
            self.dismiss(animated: false, completion: nil)
          }
        }
      })
      
      // run the animation
      hideCard.startAnimation()
    }
    
    private func dimAlphaWithCardTopConstraint(value: CGFloat) -> CGFloat {
      let fullDimAlpha : CGFloat = 0.7
      
      // ensure safe area height and safe area bottom padding is not nil
      guard let safeAreaHeight = UIApplication.shared.keyWindow?.safeAreaLayoutGuide.layoutFrame.size.height,
        let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom else {
        return fullDimAlpha
      }
      
      // when card view top constraint value is equal to this,
      // the dimmer view alpha is dimmest (0.7)
      let fullDimPosition = (safeAreaHeight + bottomPadding) / 2.0
      
      // when card view top constraint value is equal to this,
      // the dimmer view alpha is lightest (0.0)
      let noDimPosition = safeAreaHeight + bottomPadding
      
      // if card view top constraint is lesser than fullDimPosition
      // it is dimmest
      if value < fullDimPosition {
        return fullDimAlpha
      }
      
      // if card view top constraint is more than noDimPosition
      // it is dimmest
      if value > noDimPosition {
        return 0.0
      }
      
      // else return an alpha value in between 0.0 and 0.7 based on the top constraint value
      return fullDimAlpha * 1 - ((value - fullDimPosition) / fullDimPosition)
    }
    
}
