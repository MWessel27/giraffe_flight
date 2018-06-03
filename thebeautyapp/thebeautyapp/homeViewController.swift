//
//  ViewController.swift
//  thebeautyapp
//
//  Created by Mikalangelo Wessel on 5/21/18.
//  Copyright © 2018 giraffeflight. All rights reserved.
//

import UIKit

class homeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightBarButton = UIBarButtonItem(title: "Products", style: UIBarButtonItemStyle.plain, target: self, action: #selector(goToProdList))
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        let leftBarButton = UIBarButtonItem(title: "Stats", style: UIBarButtonItemStyle.plain, target: self, action: #selector(goToStatsCal))
        self.navigationItem.leftBarButtonItem = leftBarButton
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

