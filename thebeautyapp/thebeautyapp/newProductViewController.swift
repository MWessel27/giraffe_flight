//
//  newProductViewController.swift
//  thebeautyapp
//
//  Created by Mikalangelo Wessel on 1/14/19.
//  Copyright © 2019 giraffeflight. All rights reserved.
//

import UIKit
import os.log

class newProductViewController: UIViewController {
    
    @IBOutlet weak var submitNewProductBtn: UIButton!
    @IBOutlet weak var newProductField: UITextField!
    @IBOutlet weak var sunButton: UIButton!
    @IBOutlet weak var moonButton: UIButton!
    
    let gradientLayer = CAGradientLayer()
    var sunSelected = 0
    var moonSelected = 0
    var product: Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let colorTop, colorBottom: CGColor
        
        colorTop =  UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        colorBottom = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        if let product = product {
            navigationItem.title = product.name
            newProductField.text = product.name
            
            if(product.ampm == 0) {
                sunSelected = 1;
                moonSelected = 1;
                sunButton.layer.cornerRadius = 5
                sunButton.backgroundColor = .black
                //setGradientBackground(indicator: "sun")
                moonButton.layer.cornerRadius = 5
                moonButton.backgroundColor = .black
                setGradientBackground(indicator: "shared")
            } else if(product.ampm == 1){
                sunSelected = 1;
                sunButton.layer.cornerRadius = 5
                sunButton.backgroundColor = .black
                setGradientBackground(indicator: "sun")
            } else if(product.ampm == 2) {
                moonSelected = 2;
                moonButton.layer.cornerRadius = 5
                moonButton.backgroundColor = .black
                setGradientBackground(indicator: "moon")
            }
        } else {
                sunSelected = 1
                sunButton.layer.cornerRadius = 5
                sunButton.backgroundColor = .white
                setGradientBackground(indicator: "sun")
        }
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIButton, button === submitNewProductBtn else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let name = newProductField.text ?? ""
        var timeOfDay = 0
        
        if(sunSelected == 1 && moonSelected == 1) {
            timeOfDay = 0
        } else if(sunSelected == 1) {
            timeOfDay = 1
        } else if(moonSelected == 1) {
            timeOfDay = 2
        }
        
        // Set the meal to be passed to MealTableViewController after the unwind segue.
        product = Product(name: name, daily: true, rating: 1, ampm: timeOfDay, cat: "mine")
    }
    
    func setGradientBackground(indicator: String) {
        
        let colorTop, colorBottom: CGColor
        
        if(indicator == "sun") {
            colorTop =  UIColor(red: 255.0/255.0, green: 152.0/255.0, blue: 0.0/255.0, alpha: 1.0).cgColor
            colorBottom = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        } else if (indicator == "moon"){
            colorTop =  UIColor(red: 137.0/255.0, green: 137.0/255.0, blue: 137.0/255.0, alpha: 1.0).cgColor
            colorBottom = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        } else if(indicator == "shared"){
            colorTop =  UIColor(red: 255.0/255.0, green: 152.0/255.0, blue: 0.0/255.0, alpha: 1.0).cgColor
            colorBottom = UIColor(red: 137.0/255.0, green: 137.0/255.0, blue: 137.0/255.0, alpha: 1.0).cgColor
        } else {
            colorTop =  UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
            colorBottom = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        }
        
        gradientLayer.colors = [colorTop, colorBottom]
    }
    
    @IBAction func sunButtonClick(_ sender: Any) {
        
        if(sunSelected == 0) {
            sunButton.layer.cornerRadius = 5
            sunButton.backgroundColor = .white
            if(moonSelected == 1) {
                setGradientBackground(indicator: "shared")
            } else {
                setGradientBackground(indicator: "sun")
            }
            sunSelected = 1
        } else {
            sunButton.layer.cornerRadius = 0
            sunButton.backgroundColor = .clear
            if(moonSelected == 1) {
                setGradientBackground(indicator: "moon")
            } else {
                setGradientBackground(indicator: "")
            }
            sunSelected = 0
        }
    }
    
    @IBAction func moonButtonClick(_ sender: Any) {
        if(moonSelected == 0) {
            moonButton.layer.cornerRadius = 5
            moonButton.backgroundColor = .white
            if(sunSelected == 1) {
                setGradientBackground(indicator: "shared")
            } else {
                setGradientBackground(indicator: "moon")
            }
            moonSelected = 1
        } else {
            moonButton.layer.cornerRadius = 0
            moonButton.backgroundColor = .clear
            if(sunSelected == 1) {
                setGradientBackground(indicator: "sun")
            } else {
                setGradientBackground(indicator: "")
            }
            moonSelected = 0
        }
    }
}
