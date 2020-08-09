//
//  RatingViewController.swift
//  Flawless
//
//  Created by Mikalangelo Wessel on 8/4/20.
//  Copyright © 2020 giraffeflight. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import os.log
import Firebase
import Lottie

class RatingViewController: UIViewController {
    
    @IBOutlet weak var backingImageView: UIImageView!
    @IBOutlet weak var dimmerView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var handleView: UIView!
    @IBOutlet weak var ratingCardHeaderLabel: UILabel!
    @IBOutlet var ratingSetAnimationView: AnimationView!
    @IBOutlet var ratingControl: RatingControl!
    @IBOutlet weak var cardViewTopConstraint: NSLayoutConstraint!
    
    enum CardViewState {
        case expanded
        case normal
    }

    // default card view state is normal
    var cardViewState : CardViewState = .normal

    // to store the card view top constraint value before the dragging start
    // default is 60 pt from safe area top
    var cardPanStartingTopConstant : CGFloat = 60.0
    
    // to store backing (snapshot) image
    var backingImage: UIImage?
    
    var selectedDate: String = ""
    var todaysDate: String = ""
    
    var ratings = [Rating]()
    var dayRating: Rating?
    
    var currentStreak = [Streak]()
    
    override func viewDidLoad() {
      super.viewDidLoad()
        
        self.ratingControl.delegate = self
        ratingCardHeaderLabel.text = "Set Your Skin Health Rating"
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        todaysDate = formatter.string(from: date)
        selectedDate = todaysDate
        
        setDayRating()
        
        if let todaysStreak = loadStreak() {
            currentStreak = todaysStreak
        }

      // update the backing image view
      backingImageView.image = backingImage
        
        // round the top left and top right corner of card view
        cardView.clipsToBounds = true
        cardView.layer.cornerRadius = 10.0
        cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        // round the handle view
        handleView.clipsToBounds = true
        handleView.layer.cornerRadius = 3.0
        
        // hide the card view at the bottom when the View first load
        if let safeAreaHeight = UIApplication.shared.keyWindow?.safeAreaLayoutGuide.layoutFrame.size.height,
          let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom {
          cardViewTopConstraint.constant = safeAreaHeight + bottomPadding
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)

      showCard()
    }
    
    // this function will be called when user pan/drag the view
    @IBAction func viewPanned(_ panRecognizer: UIPanGestureRecognizer) {
      let velocity = panRecognizer.velocity(in: self.view)
      let translation = panRecognizer.translation(in: self.view)
      
      switch panRecognizer.state {
      case .began:
        cardPanStartingTopConstant = cardViewTopConstraint.constant
        
      case .changed:
        if self.cardPanStartingTopConstant + translation.y > 30.0 {
          self.cardViewTopConstraint.constant = self.cardPanStartingTopConstant + translation.y
        }
        
        // change the dimmer view alpha based on how much user has dragged
        dimmerView.alpha = dimAlphaWithCardTopConstraint(value: self.cardViewTopConstraint.constant)

      case .ended:
        if velocity.y > 1500.0 {
          hideCardAndGoBack()
          return
        }
        
        if let safeAreaHeight = UIApplication.shared.keyWindow?.safeAreaLayoutGuide.layoutFrame.size.height,
          let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom {
          
          if self.cardViewTopConstraint.constant < (safeAreaHeight + bottomPadding) * 0.25 {
            showCard(atState: .expanded)
          } else if self.cardViewTopConstraint.constant < (safeAreaHeight) - 70 {
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

    //MARK: Animations
    private func showCard(atState: CardViewState = .normal) {
      // ensure there's no pending layout changes before animation runs
      self.view.layoutIfNeeded()
      
      // set the new top constraint value for card view
      // card view won't move up just yet, we need to call layoutIfNeeded()
      // to tell the app to refresh the frame/position of card view
      if let safeAreaHeight = UIApplication.shared.keyWindow?.safeAreaLayoutGuide.layoutFrame.size.height,
        let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom {
        
        if atState == .expanded {
          // if state is expanded, top constraint is 60pt away from safe area top
          cardViewTopConstraint.constant = 60.0
        } else {
          cardViewTopConstraint.constant = (safeAreaHeight + bottomPadding) / 2.0
        }
        
        cardPanStartingTopConstant = cardViewTopConstraint.constant
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
        cardViewTopConstraint.constant = safeAreaHeight + bottomPadding
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
    
    //MARK: Day Rating Component
    private func loadRatings() -> [Rating]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Rating.ArchiveURL.path) as? [Rating]
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
                Analytics.logEvent("day_streak", parameters: [
                "streak": currentStreak[0].streak as NSObject
                ])
                rate.rating = rating
                setRating = true
            }
        }
        
        if(!setRating) {
            Analytics.logEvent("set_rating", parameters: [
                "rating": rating as NSObject
                ])
            Analytics.logEvent("day_streak", parameters: [
                "streak": currentStreak[0].streak as NSObject
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
        startRatingAnimation()
    }
    
    func startRatingAnimation() {
        ratingControl.isHidden = true
        ratingCardHeaderLabel.text = "Great Job!"
        let starRatingAnimationSubView = AnimationView(name: "starRatingAnimation")
        let testLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 400, height: 400))
        if(!currentStreak.isEmpty && !currentStreak[0].setToday) {
            testLabel.text = String(currentStreak[0].streak + 1)
        } else if(!currentStreak.isEmpty && currentStreak[0].setToday) {
            testLabel.text = String(currentStreak[0].streak)
        } else {
            testLabel.text = "1"
        }
        testLabel.font = UIFont.boldSystemFont(ofSize: 44.0)
        testLabel.textAlignment = .center
        starRatingAnimationSubView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
        testLabel.center = CGPoint(x: ratingSetAnimationView.bounds.size.width/2+3, y: ratingSetAnimationView.bounds.size.height/2+150)
        starRatingAnimationSubView.center = CGPoint(x: ratingSetAnimationView.bounds.size.width/2, y: ratingSetAnimationView.bounds.size.height/2+150)
        ratingSetAnimationView.addSubview(starRatingAnimationSubView)
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) {
            (nil) in
            self.ratingSetAnimationView.addSubview(testLabel)
        }
        starRatingAnimationSubView.play(completion: { (finished) in
            if finished {
              print("Animation Complete")
                Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { (nil) in
                    self.hideCardAndGoBack()
                }
            } else {
              print("Animation cancelled")
            }
        })
    }
    
    private func loadStreak() -> [Streak]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Streak.ArchiveURL.path) as? [Streak]
    }
    
    private func saveStreak() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(currentStreak, toFile: Streak.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Streak successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save streak...", log: OSLog.default, type: .error)
        }
    }
}

extension RatingViewController: RatingViewDelegate {
    func setSelectedRating(rating: Int) {
        saveRating(rating: rating, date: selectedDate)
        if(currentStreak.isEmpty) {
            let tempStreak = Streak(setToday: true, streak: 1)
            currentStreak.append(tempStreak!)
        } else if(!currentStreak[0].setToday) {
            currentStreak[0].streak += 1
            currentStreak[0].setToday = true
        }
        
        saveStreak()
    }
}

