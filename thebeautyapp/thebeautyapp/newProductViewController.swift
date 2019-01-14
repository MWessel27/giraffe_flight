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
    
    @IBOutlet weak var sunButton: UIButton!
    @IBOutlet weak var moonButton: UIButton!
    let gradientLayer = CAGradientLayer()
    var selectFlag = 0
    
    func setGradientBackground(indicator: String) {
        
        let colorTop, colorBottom: CGColor
        
        if(indicator == "sun") {
            colorTop =  UIColor(red: 255.0/255.0, green: 152.0/255.0, blue: 0.0/255.0, alpha: 1.0).cgColor
            colorBottom = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        } else if (indicator == "moon"){
            colorTop =  UIColor(red: 137.0/255.0, green: 137.0/255.0, blue: 137.0/255.0, alpha: 1.0).cgColor
            colorBottom = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        } else {
            colorTop =  UIColor(red: 255.0/255.0, green: 152.0/255.0, blue: 0.0/255.0, alpha: 1.0).cgColor
            colorBottom = UIColor(red: 137.0/255.0, green: 137.0/255.0, blue: 137.0/255.0, alpha: 1.0).cgColor
        }
        
        gradientLayer.colors = [colorTop, colorBottom]
    }
    
    @IBAction func sunButtonClick(_ sender: Any) {
        if(selectFlag == 1) {
            setGradientBackground(indicator: "both")
            selectFlag = 0
        } else {
            setGradientBackground(indicator: "sun")
            //moonButton.backgroundColor = .clear
            sunButton.layer.cornerRadius = 5
            sunButton.backgroundColor = .white
            selectFlag = 1
        }
    }
    
    @IBAction func moonButtonClick(_ sender: Any) {
        if(selectFlag == 1) {
            setGradientBackground(indicator: "both")
            selectFlag = 0
        } else {
            //sunButton.backgroundColor = .clear
            setGradientBackground(indicator: "moon")
            moonButton.layer.cornerRadius = 5
            moonButton.backgroundColor = .white
            selectFlag = 1
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let colorTop, colorBottom: CGColor
        
        colorTop =  UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        colorBottom = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)

    }
}
