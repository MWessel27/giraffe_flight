//
//  GettingStartedViewController.swift
//  thebeautyapp
//
//  Created by Mikalangelo Wessel on 3/21/19.
//  Copyright © 2019 giraffeflight. All rights reserved.
//

import UIKit

class GettingStartedViewController: UIViewController {
    
    @IBOutlet weak var gsAddProductButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gsAddProductButton.addTarget(self, action: #selector(gsAddProduct), for: .touchUpInside)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func dismissModal(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func gsAddProduct(_ sender: Any) {

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
