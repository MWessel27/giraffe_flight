//
//  AddProductViewController.swift
//  Flawless
//
//  Created by Mikalangelo Wessel on 5/25/20.
//  Copyright © 2020 giraffeflight. All rights reserved.
//

import UIKit
import CoreData
import os.log
import Firebase

class AddProductViewController: UIViewController, UITextFieldDelegate {
    
    var delegate: addEditProduct?

    // card view items
    @IBOutlet weak var backingImageView: UIImageView!
    @IBOutlet weak var dimmerView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var cardViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var handleView: UIView!
    
    // form fields
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var newProductField: UITextField!
    @IBOutlet weak var timeOfDaySelector: UISegmentedControl!
    
    @IBOutlet weak var addProductButton: UIButton!
    
    @IBOutlet weak var daySelectStackView: UIStackView!
    @IBOutlet weak var everyDayButton: UIButton!
    
    @IBOutlet weak var sundayButton: UIButton!
    @IBOutlet weak var mondayButton: UIButton!
    @IBOutlet weak var tuesdayButton: UIButton!
    @IBOutlet weak var wednesdayButton: UIButton!
    @IBOutlet weak var thursdayButton: UIButton!
    @IBOutlet weak var fridayButton: UIButton!
    @IBOutlet weak var saturdayButton: UIButton!
    
    var usedActivities: [UsedActivity] = []
    
    var daysOfWeek = [0,0,0,0,0,0,0]
    
    var product: Product?
    var products = [Product]()
    
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
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")

        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false

        view.addGestureRecognizer(tap)
        
        if let savedProds = loadProducts() {
            products += savedProds
        }
        
        // setup bottom button
        addProductButton.clipsToBounds = true
        addProductButton.layer.cornerRadius = 5
        addProductButton.layer.borderWidth = 1

        // update the backing image view
        backingImageView.image = backingImage
        
        // round the top left and top right corner of card view
        cardView.clipsToBounds = true
        cardView.layer.cornerRadius = 10.0
        cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
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
        
        // round the handle view
        handleView.clipsToBounds = true
        handleView.layer.cornerRadius = 3.0
        
        // setup day selection buttons
        everyDayButton.setBackgroundColor(color: UIColor.black, forState: .selected)
        everyDayButton.setTitleColor(UIColor.white, for: .selected)
//        everyDayButton.isSelected = true
        everyDayButton.layer.cornerRadius = 10
//        if(everyDayButton.isSelected) {
//            everyDayButton.titleLabel?.font = UIFont.systemFont(ofSize: 19.0, weight: UIFont.Weight.bold)
//        }
        
        sundayButton.setBackgroundColor(color: UIColor.black, forState: .selected)
        sundayButton.setTitleColor(UIColor.white, for: .selected)
//        sundayButton.isSelected = false
        sundayButton.layer.cornerRadius = 10
        
        mondayButton.setBackgroundColor(color: UIColor.black, forState: .selected)
        mondayButton.setTitleColor(UIColor.white, for: .selected)
//        mondayButton.isSelected = false
        mondayButton.layer.cornerRadius = 10

        tuesdayButton.setBackgroundColor(color: UIColor.black, forState: .selected)
        tuesdayButton.setTitleColor(UIColor.white, for: .selected)
//        tuesdayButton.isSelected = false
        tuesdayButton.layer.cornerRadius = 10
        
        wednesdayButton.setBackgroundColor(color: UIColor.black, forState: .selected)
        wednesdayButton.setTitleColor(UIColor.white, for: .selected)
//        wednesdayButton.isSelected = false
        wednesdayButton.layer.cornerRadius = 10
        
        thursdayButton.setBackgroundColor(color: UIColor.black, forState: .selected)
        thursdayButton.setTitleColor(UIColor.white, for: .selected)
//        thursdayButton.isSelected = false
        thursdayButton.layer.cornerRadius = 10
        
        fridayButton.setBackgroundColor(color: UIColor.black, forState: .selected)
        fridayButton.setTitleColor(UIColor.white, for: .selected)
//        fridayButton.isSelected = false
        fridayButton.layer.cornerRadius = 10
        
        saturdayButton.setBackgroundColor(color: UIColor.black, forState: .selected)
        saturdayButton.setTitleColor(UIColor.white, for: .selected)
//        saturdayButton.isSelected = false
        saturdayButton.layer.cornerRadius = 10
        
        if let product = product {
            // editing an existing product
            self.newProductField.delegate = self
            titleLabel.text = "Edit " + product.name
            newProductField.text = product.name
            
            usedActivities = product.usedActivities
            
            if(product.ampm == 0) {
                timeOfDaySelector.selectedSegmentIndex = 2
            } else if(product.ampm == 1){
                timeOfDaySelector.selectedSegmentIndex = 0
            } else if(product.ampm == 2) {
                timeOfDaySelector.selectedSegmentIndex = 1
            }
            
            if(product.daily) {
                everyDayButton.layer.cornerRadius = 10
                everyDayButton.isSelected = true
                
                sundayButton.isSelected = false
                mondayButton.isSelected = false
                tuesdayButton.isSelected = false
                wednesdayButton.isSelected = false
                thursdayButton.isSelected = false
                fridayButton.isSelected = false
                saturdayButton.isSelected = false
                for n in daysOfWeek {
                    daysOfWeek[n] = 0
                }
            } else {
                if(product.onSunday == 1) {
                    sundayButton.isSelected = true
                    daysOfWeek[0] = 1
                }
                if(product.onMonday == 1) {
                    mondayButton.isSelected = true
                    daysOfWeek[1] = 1
                }
                if(product.onTuesday == 1) {
                    tuesdayButton.isSelected = true
                    daysOfWeek[2] = 1
                }
                if(product.onWednesday == 1) {
                    wednesdayButton.isSelected = true
                    daysOfWeek[3] = 1
                }
                if(product.onThursday == 1) {
                    thursdayButton.isSelected = true
                    daysOfWeek[4] = 1
                }
                if(product.onFriday == 1) {
                    fridayButton.isSelected = true
                    daysOfWeek[5] = 1
                }
                if(product.onSaturday == 1) {
                    saturdayButton.isSelected = true
                    daysOfWeek[6] = 1
                }
            }
        } else {
            // adding a new product

            self.newProductField.delegate = self
//            self.newProductField.becomeFirstResponder()

            addProductButton.isEnabled = false
            addProductButton.alpha = 0.4

            everyDayButton.isSelected = true
            everyDayButton.layer.cornerRadius = 5
            timeOfDaySelector.selectedSegmentIndex = 2
        }
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func prodNameChanged(_ sender: Any) {
        if(newProductField.text?.isEmpty == false) {
            addProductButton.isEnabled = true
            addProductButton.alpha = 1.0
        } else {
            addProductButton.isEnabled = false
            addProductButton.alpha = 0.5
        }
    }
    
    @IBAction func newProductFieldClick(_ sender: Any) {
        showCard(atState: .expanded)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func sundayButtonClick(_ sender: Any) {
        if(daysOfWeek[0] == 1) {
            sundayButton.isSelected = false
            daysOfWeek[0] = 0
        } else {
            sundayButton.isSelected = true
            daysOfWeek[0] = 1
        }
        checkEveryday()
    }
    
    
    @IBAction func mondayButtonClick(_ sender: Any) {
        if(daysOfWeek[1] == 1) {
            mondayButton.isSelected = false
            daysOfWeek[1] = 0
        } else {
            mondayButton.isSelected = true
            daysOfWeek[1] = 1
        }
        checkEveryday()
    }
    
    @IBAction func tuesdayButtonClick(_ sender: Any) {
        if(daysOfWeek[2] == 1) {
            tuesdayButton.isSelected = false
            daysOfWeek[2] = 0
        } else {
            tuesdayButton.isSelected = true
            daysOfWeek[2] = 1
        }
        checkEveryday()
    }
    
    @IBAction func wednesdayButtonClick(_ sender: Any) {
        if(daysOfWeek[3] == 1) {
            wednesdayButton.isSelected = false
            daysOfWeek[3] = 0
        } else {
            wednesdayButton.isSelected = true
            daysOfWeek[3] = 1
        }
        checkEveryday()
    }
    
    @IBAction func thursdayButtonClick(_ sender: Any) {
        if(daysOfWeek[4] == 1) {
            thursdayButton.isSelected = false
            daysOfWeek[4] = 0
        } else {
            thursdayButton.isSelected = true
            daysOfWeek[4] = 1
        }
        checkEveryday()
    }
    
    @IBAction func fridayButtonClick(_ sender: Any) {
        if(daysOfWeek[5] == 1) {
            fridayButton.isSelected = false
            daysOfWeek[5] = 0
        } else {
            fridayButton.isSelected = true
            daysOfWeek[5] = 1
        }
        checkEveryday()
    }
    
    @IBAction func saturdayButtonClick(_ sender: Any) {
        if(daysOfWeek[6] == 1) {
            saturdayButton.isSelected = false
            daysOfWeek[6] = 0
        } else {
            saturdayButton.isSelected = true
            daysOfWeek[6] = 1
        }
        checkEveryday()
    }
    
    private func loadProducts() -> [Product]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Product.ArchiveURL.path) as? [Product]
    }
    
    @IBAction func dimmerViewTapped(_ tapRecognizer: UITapGestureRecognizer) {
      hideCardAndGoBack()
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
    
    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)

      showCard()
    }
    
    // default to show card at normal state, if showCard() is called without parameter
    private func showCard(atState: CardViewState = .normal) {
       
      // ensure there's no pending layout changes before animation runs
      self.view.layoutIfNeeded()
        
        daySelectStackView.isHidden = true
        everyDayButton.isHidden = true
      
      // set the new top constraint value for card view
      // card view won't move up just yet, we need to call layoutIfNeeded()
      // to tell the app to refresh the frame/position of card view
      if let safeAreaHeight = UIApplication.shared.keyWindow?.safeAreaLayoutGuide.layoutFrame.size.height,
        let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom {
        
        if atState == .expanded {
          // if state is expanded, top constraint is 30pt away from safe area top
          cardViewTopConstraint.constant = 60.0
            daySelectStackView.isHidden = false
            everyDayButton.isHidden = false
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
    
    
    @IBAction func addProductButtonTapped(_ sender: Any) {
        let name = newProductField.text ?? ""
        var timeOfDay = 0
        var timeOfDayReadable = "Morning & Night"
        var daily = false
    
        if(everyDayButton.isSelected || !daysOfWeek.contains(1)) {
            daily = true
        }
    
        if(timeOfDaySelector.selectedSegmentIndex == 0) {
            timeOfDay = 1
            timeOfDayReadable = "Morning"
        } else if (timeOfDaySelector.selectedSegmentIndex == 1) {
            timeOfDay = 2
            timeOfDayReadable = "Night"
        } else {
            timeOfDay = 0
        }
            
        Analytics.logEvent("add_product", parameters: [
            "productName": name as NSObject,
            "timeOfDayUsed": timeOfDayReadable as NSObject,
            "daily": daily as NSObject,
            "onSunday": daysOfWeek[0],
            "onMonday": daysOfWeek[1],
            "onTuesday": daysOfWeek[2],
            "onWednesday": daysOfWeek[3],
            "onThursday": daysOfWeek[4],
            "onFriday": daysOfWeek[5],
            "onSaturday": daysOfWeek[6]
            ])
    
        // Set the meal to be passed to MealTableViewController after the unwind segue.
        product = Product(name: name, daily: daily, rating: 1, ampm: timeOfDay, cat: "mine", onSunday: daysOfWeek[0], onMonday: daysOfWeek[1], onTuesday: daysOfWeek[2], onWednesday: daysOfWeek[3], onThursday: daysOfWeek[4], onFriday: daysOfWeek[5], onSaturday: daysOfWeek[6], usedActivities: usedActivities)
        
        hideCardAndGoBack()
        self.delegate?.addProduct(product: product!)
    }
    
    // day of week button functions
    
    func checkEveryday() {
        if(!daysOfWeek.contains(0)) {
            everyDayButton.layer.cornerRadius = 5
            everyDayButton.isSelected = true
            resetAllButtons()
        } else {
            everyDayButton.isSelected = false
        }
    }
    
    func resetAllButtons() {
        sundayButton.isSelected = false
        mondayButton.isSelected = false
        tuesdayButton.isSelected = false
        wednesdayButton.isSelected = false
        thursdayButton.isSelected = false
        fridayButton.isSelected = false
        saturdayButton.isSelected = false
        
        for n in 0 ..< daysOfWeek.count {
            daysOfWeek[n] = 0
        }
    }
    
    
    @IBAction func everyDayButtonClicked(_ sender: Any) {
        if(everyDayButton.isSelected == true) {
            everyDayButton.isSelected = false
        } else {
            everyDayButton.layer.cornerRadius = 5
            everyDayButton.isSelected = true
            resetAllButtons()
        }
    }
    
}
