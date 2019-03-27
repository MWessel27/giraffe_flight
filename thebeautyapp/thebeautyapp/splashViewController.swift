//
//  splashViewController.swift
//  thebeautyapp
//
//  Created by Mikalangelo Wessel on 6/3/18.
//  Copyright © 2018 giraffeflight. All rights reserved.
//

import UIKit

class splashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(timeToMoveOn), userInfo: nil, repeats: false)
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timeToMoveOn), userInfo: nil, repeats: false)
    }
    
    @objc func timeToMoveOn() {
        self.performSegue(withIdentifier: "goToMainUI", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
