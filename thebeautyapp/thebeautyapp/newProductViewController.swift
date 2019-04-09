//
//  newProductViewController.swift
//  thebeautyapp
//
//  Created by Mikalangelo Wessel on 1/14/19.
//  Copyright © 2019 giraffeflight. All rights reserved.
//

import UIKit
import os.log
import Firebase

class newProductViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var submitNewProductBtn: UIButton!
    @IBOutlet weak var newProductField: UITextField!
    @IBOutlet weak var sunButton: UIButton!
    @IBOutlet weak var moonButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    // days of week buttons
    @IBOutlet weak var sundayButton: UIButton!
    @IBOutlet weak var mondayButton: UIButton!
    @IBOutlet weak var tuesdayButton: UIButton!
    @IBOutlet weak var wednesdayButton: UIButton!
    @IBOutlet weak var thursdayButton: UIButton!
    @IBOutlet weak var fridayButton: UIButton!
    @IBOutlet weak var saturdayButton: UIButton!
    
    @IBOutlet weak var everyDayButton: UIButton!
    
    let notification = UINotificationFeedbackGenerator()
    
    var daysOfWeek = [0,0,0,0,0,0,0]
    
    var usedActivities: [UsedActivity] = []
    
    let gradientLayer = CAGradientLayer()
    var sunSelected = 0
    var moonSelected = 0
    var product: Product?
    var products = [Product]()
    
    let purple:UIColor = UIColor(red: 156.0/255.0, green: 149.0/255.0, blue: 220.0/255.0, alpha: 1)
    let mintgreen:UIColor = UIColor(red: 174.0/255.0, green: 255.0/255.0, blue: 216.0/255.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closeButton.isHidden = true
        
        if(presentingViewController == nil) {
            closeButton.isHidden = false
        }
        
        self.view.addSubview(submitNewProductBtn)
        
        submitNewProductBtn.translatesAutoresizingMaskIntoConstraints = false
        
        submitNewProductBtn.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        submitNewProductBtn.heightAnchor.constraint(equalToConstant: 90).isActive = true
        submitNewProductBtn.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        
        if let savedProds = loadProducts() {
            products += savedProds
        }
        
        sundayButton.setBackgroundColor(color: purple, forState: .selected)
        mondayButton.setBackgroundColor(color: purple, forState: .selected)
        tuesdayButton.setBackgroundColor(color: purple, forState: .selected)
        wednesdayButton.setBackgroundColor(color: purple, forState: .selected)
        thursdayButton.setBackgroundColor(color: purple, forState: .selected)
        fridayButton.setBackgroundColor(color: purple, forState: .selected)
        saturdayButton.setBackgroundColor(color: purple, forState: .selected)
        
        everyDayButton.setBackgroundColor(color: purple, forState: .selected)
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        let colorTop, colorBottom: CGColor
        
        colorTop =  UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        colorBottom = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        if let product = product {
            // editing an existing product
            self.newProductField.delegate = self
            navigationItem.title = "Edit " + product.name
            newProductField.text = product.name
            
            usedActivities = product.usedActivities
            
            if(product.ampm == 0) {
                sunSelected = 1;
                moonSelected = 1;
                setGradientBackground(indicator: "shared")
            } else if(product.ampm == 1){
                sunSelected = 1;
                setGradientBackground(indicator: "sun")
            } else if(product.ampm == 2) {
                moonSelected = 1;
                setGradientBackground(indicator: "moon")
            }
            
            if(product.daily) {
                everyDayButton.layer.cornerRadius = 5
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
            self.newProductField.becomeFirstResponder()
            
            submitNewProductBtn.isEnabled = false
            submitNewProductBtn.alpha = 0.4
            
            everyDayButton.isSelected = true
            everyDayButton.layer.cornerRadius = 5
            sunSelected = 1
            setGradientBackground(indicator: "sun")
        }
    }
    
    private func loadProducts() -> [Product]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Product.ArchiveURL.path) as? [Product]
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    var isModal: Bool {
        return self.presentingViewController?.presentedViewController == self
            || (self.navigationController != nil && self.navigationController?.presentingViewController?.presentedViewController == self.navigationController)
            || self.tabBarController?.presentingViewController is UITabBarController
    }
    
    @IBAction func dismissModal(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIButton, button === submitNewProductBtn else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        notification.notificationOccurred(.success)
    
        let name = newProductField.text ?? ""
        var timeOfDay = 0
        var timeOfDayReadable = "Morning & Night"
        var daily = false
    
        if(everyDayButton.isSelected || !daysOfWeek.contains(1)) {
            daily = true
        }
    
        if(sunSelected == 1 && moonSelected == 1) {
            timeOfDay = 0
        } else if(sunSelected == 1) {
            timeOfDay = 1
            timeOfDayReadable = "Morning"
        } else if(moonSelected == 1) {
            timeOfDay = 2
            timeOfDayReadable = "Night"
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
    }
    
    func setGradientBackground(indicator: String) {
        
        if(indicator == "sun") {
            sunButton.layer.cornerRadius = 5
            sunButton.backgroundColor = mintgreen
            moonButton.layer.cornerRadius = 0
            moonButton.backgroundColor = .clear
        } else if (indicator == "moon"){
            moonButton.layer.cornerRadius = 5
            moonButton.backgroundColor = mintgreen
            sunButton.layer.cornerRadius = 0
            sunButton.backgroundColor = .clear
        } else {
            sunButton.layer.cornerRadius = 5
            sunButton.backgroundColor = mintgreen
            moonButton.layer.cornerRadius = 5
            moonButton.backgroundColor = mintgreen
        }
        
    }

    @IBAction func prodNameFieldChanged(_ sender: Any) {
        if(newProductField.text?.isEmpty == false) {
            submitNewProductBtn.isEnabled = true
            submitNewProductBtn.alpha = 1.0
        } else {
            submitNewProductBtn.isEnabled = false
            submitNewProductBtn.alpha = 0.5
        }
    }
    
    @IBAction func sunButtonClick(_ sender: Any) {
        dismissKeyboard()
        if(sunSelected == 0) {
            sunSelected = 1
            if(moonSelected == 1) {
                setGradientBackground(indicator: "shared")
            } else {
                setGradientBackground(indicator: "sun")
            }
        } else {
            sunSelected = 0
            if(moonSelected == 1) {
                setGradientBackground(indicator: "moon")
            } else {
                setGradientBackground(indicator: "")
            }
        }
    }
    
    @IBAction func moonButtonClick(_ sender: Any) {
        dismissKeyboard()
        if(moonSelected == 0) {
            moonSelected = 1
            if(sunSelected == 1) {
                setGradientBackground(indicator: "shared")
            } else {
                setGradientBackground(indicator: "moon")
            }
        } else {
            moonSelected = 0
            if(sunSelected == 1) {
                setGradientBackground(indicator: "sun")
            } else {
                setGradientBackground(indicator: "")
            }
        }
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
    
    @IBAction func everyDayButtonClick(_ sender: Any) {
        if(everyDayButton.isSelected == true) {
            everyDayButton.isSelected = false
        } else {
            everyDayButton.layer.cornerRadius = 5
            everyDayButton.isSelected = true
            resetAllButtons()
        }
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
}

extension UIButton {
    
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setTitleColor(UIColor.white, for: forState)
        self.setBackgroundImage(colorImage, for: forState)
    }
}
