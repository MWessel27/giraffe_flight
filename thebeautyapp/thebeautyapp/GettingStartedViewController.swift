//
//  GettingStartedViewController.swift
//  thebeautyapp
//
//  Created by Mikalangelo Wessel on 3/21/19.
//  Copyright © 2019 giraffeflight. All rights reserved.
//

import UIKit

class GettingStartedViewController: UIViewController {
    
    var products = [Product]()
    
    @IBOutlet weak var gsAddProductButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let savedProds = loadProducts() {
            products += savedProds
        }
        
        gsAddProductButton.addTarget(self, action: #selector(gsAddProduct), for: .touchUpInside)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func dismissModal(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func unwindToProductList(sender: UIStoryboardSegue) {
        self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
        if let sourceViewController = sender.source as? newProductViewController, let product = sourceViewController.product {
            products.append(product)
            saveProducts()
        }
    }
    
    private func saveProducts() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(products, toFile: Product.ArchiveURL.path)
        if isSuccessfulSave {
            print("Products successfully saved.")
        } else {
            print("Failed to save Products...")
        }
    }
    
    
    private func loadProducts() -> [Product]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Product.ArchiveURL.path) as? [Product]
    }
    
    
    @IBAction func gsAddProduct(_ sender: Any) {
        if let presentedViewController = self.storyboard?.instantiateViewController(withIdentifier: "newProductViewController") {
            presentedViewController.providesPresentationContextTransitionStyle = true
            presentedViewController.definesPresentationContext = true
            presentedViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext;
            presentedViewController.view.backgroundColor = UIColor.init(white: 0.4, alpha: 0.8)
            self.present(presentedViewController, animated: true, completion: nil)
        }
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
