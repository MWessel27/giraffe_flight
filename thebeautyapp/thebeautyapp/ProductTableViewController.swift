//
//  productViewController.swift
//  thebeautyapp
//
//  Created by Mikalangelo Wessel on 6/3/18.
//  Copyright © 2018 giraffeflight. All rights reserved.
//

import UIKit
import os.log
import Firebase
import UserNotifications

class ProductTableViewController: UITableViewController {
    
    private let imageView = UIImageView(image: UIImage(named: "add-icon"))
    
    var products = [Product]()
    
    @IBOutlet var productTableView: UITableView!
    
//    private var floatingButton: UIButton?
//    // TODO: Replace image name with your own image:
//    private let floatingButtonImageName = "add-icon"
//    private static let buttonHeight: CGFloat = 75.0
//    private static let buttonWidth: CGFloat = 75.0
//    private let roundValue = ProductTableViewController.buttonHeight/2
//    private let trailingValue: CGFloat = 15.0
//    private let leadingValue: CGFloat = 100.0
//    private let shadowRadius: CGFloat = 2.0
//    private let shadowOpacity: Float = 0.5
//    private let shadowOffset = CGSize(width: 0.0, height: 5.0)
//    private let scaleKeyPath = "scale"
//    private let animationKeyPath = "transform.scale"
//    private let animationDuration: CFTimeInterval = 0.4
//    private let animateFromValue: CGFloat = 1.00
//    private let animateToValue: CGFloat = 1.05
//
//    public override func viewWillDisappear(_ animated: Bool) {
//        guard floatingButton?.superview != nil else {  return }
//        DispatchQueue.main.async {
//            self.floatingButton?.removeFromSuperview()
//            self.floatingButton = nil
//        }
//        super.viewWillDisappear(animated)
//    }
//
//    private func createFloatingButton() {
//        floatingButton = UIButton(type: .custom)
//        floatingButton?.translatesAutoresizingMaskIntoConstraints = false
//        floatingButton?.backgroundColor = .white
//        floatingButton?.setImage(UIImage(named: floatingButtonImageName), for: .normal)
//        floatingButton?.addTarget(self, action: #selector(doThisWhenButtonIsTapped(_:)), for: .touchUpInside)
//        constrainFloatingButtonToWindow()
//        makeFloatingButtonRound()
//        addShadowToFloatingButton()
//        addScaleAnimationToFloatingButton()
//    }
//
//    // TODO: Add some logic for when the button is tapped.
//    @IBAction private func doThisWhenButtonIsTapped(_ sender: Any) {
//        addProdList()
//        print("Button Tapped")
//    }
//
//    private func constrainFloatingButtonToWindow() {
//        DispatchQueue.main.async {
//            guard let keyWindow = UIApplication.shared.keyWindow,
//                let floatingButton = self.floatingButton else { return }
//            keyWindow.addSubview(floatingButton)
//            keyWindow.trailingAnchor.constraint(equalTo: floatingButton.trailingAnchor,
//                                                constant: self.trailingValue).isActive = true
//            keyWindow.bottomAnchor.constraint(equalTo: floatingButton.bottomAnchor,
//                                              constant: self.leadingValue).isActive = true
//            floatingButton.widthAnchor.constraint(equalToConstant: ProductTableViewController.buttonWidth).isActive = true
//            floatingButton.heightAnchor.constraint(equalToConstant: ProductTableViewController.buttonHeight).isActive = true
//        }
//    }
//
//    private func makeFloatingButtonRound() {
//        floatingButton?.layer.cornerRadius = roundValue
//    }
//
//    private func addShadowToFloatingButton() {
//        floatingButton?.layer.shadowColor = UIColor.black.cgColor
//        floatingButton?.layer.shadowOffset = shadowOffset
//        floatingButton?.layer.masksToBounds = false
//        floatingButton?.layer.shadowRadius = shadowRadius
//        floatingButton?.layer.shadowOpacity = shadowOpacity
//    }
//
//    private func addScaleAnimationToFloatingButton() {
//        // Add a pulsing animation to draw attention to button:
//        DispatchQueue.main.async {
//            let scaleAnimation: CABasicAnimation = CABasicAnimation(keyPath: self.animationKeyPath)
//            scaleAnimation.duration = self.animationDuration
//            scaleAnimation.repeatCount = .greatestFiniteMagnitude
//            scaleAnimation.autoreverses = true
//            scaleAnimation.fromValue = self.animateFromValue
//            scaleAnimation.toValue = self.animateToValue
//            self.floatingButton?.layer.add(scaleAnimation, forKey: self.scaleKeyPath)
//        }
//    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView

        guard let addProductVC = storyboard?.instantiateViewController(withIdentifier: "AddProductViewController")
        as? AddProductViewController else {
            assertionFailure("No view controller ID AddProductViewController in storyboard")
            return
        }
        
        // Delay the capture of snapshot by 0.1 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 , execute: {
          // take a snapshot of current view and set it as backingImage
          addProductVC.backingImage = self.tabBarController?.view.asImage()
          
          // present the view controller modally without animation
          self.present(addProductVC, animated: false, completion: nil)
        })
    }
    
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true

        title = "Products"

        // Initial setup for image for Large NavBar state since the the screen always has Large NavBar once it gets opened
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        navigationBar.addSubview(imageView)
        imageView.layer.cornerRadius = Const.ImageSizeForLargeState / 2
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -Const.ImageRightMargin),
            imageView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -Const.ImageBottomMarginForLargeState),
            imageView.heightAnchor.constraint(equalToConstant: Const.ImageSizeForLargeState),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
            ])
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
//        let rightBarButton = UIBarButtonItem(title: "ADD", style: UIBarButtonItem.Style.plain, target: self, action: #selector(addProdList))
//        self.navigationItem.rightBarButtonItem = rightBarButton
        
        if let savedProds = loadProducts() {
            products += savedProds
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
//        createFloatingButton()
        
        if let savedProds = loadProducts() {
            products = savedProds
        }

        productTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
//        createFloatingButton()

        if let savedProds = loadProducts() {
            products = savedProds
        }
        productTableView.reloadData()
    }
    
    
    @objc func addProdList() {
        let storyBoard : UIStoryboard = self.storyboard!
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "newProductViewController")
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func saveProducts() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(products, toFile: Product.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Products successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save Products...", log: OSLog.default, type: .error)
        }
    }
    
    
    private func loadProducts() -> [Product]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Product.ArchiveURL.path) as? [Product]
    }
    
    @IBAction func unwindToProductList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? newProductViewController, let product = sourceViewController.product {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                products[selectedIndexPath.row] = product
                productTableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                // Add a new product
                let newIndexPath = IndexPath(row: products.count, section: 0)
                
                products.append(product)
                productTableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            saveProducts()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch(segue.identifier ?? "") {
        case "AddItem":
            os_log("Adding a new meal.", log: OSLog.default, type: .debug)
        case "ShowDetail":
            guard let productDetailViewController = segue.destination as? newProductViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }

            guard let selectedProductCell = sender as? ProductTableViewCell else {
                fatalError("Unexpected sender: \(sender as Optional)")
            }

            guard let indexPath = productTableView.indexPath(for: selectedProductCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }

            let selectedProduct = products[indexPath.row]
            productDetailViewController.product = selectedProduct
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier as Optional)")
        }
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Analytics.logEvent("remove_product", parameters: [
                "productName": products[indexPath.row].name as NSObject
                ])
            // Delete the row from the data source
            products.remove(at: indexPath.row)
            saveProducts()
            productTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "ProductTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ProductTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ProductTableViewCell.")
        }
        
        let product = products[indexPath.row]
        
        cell.productLabel.text = product.name
        cell.productLabel.font = UIFont(name: "System", size: 22)
        
        let timeOfDay = products[indexPath.row].ampm
        
        if(timeOfDay == 1) {
            cell.photoImageView.image = UIImage(named: "sun-icon.png")!
        } else if(timeOfDay == 2) {
            cell.photoImageView.image = UIImage(named: "moon-icon.png")!
        } else {
            cell.photoImageView.image = UIImage(named: "sun-moon-icon.png")!
        }
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
}

private struct Const {
    /// Image height/width for Large NavBar state
    static let ImageSizeForLargeState: CGFloat = 32
    /// Margin from right anchor of safe area to right anchor of Image
    static let ImageRightMargin: CGFloat = 16
    /// Margin from bottom anchor of NavBar to bottom anchor of Image for Large NavBar state
    static let ImageBottomMarginForLargeState: CGFloat = 12
    /// Margin from bottom anchor of NavBar to bottom anchor of Image for Small NavBar state
    static let ImageBottomMarginForSmallState: CGFloat = 6
    /// Image height/width for Small NavBar state
    static let ImageSizeForSmallState: CGFloat = 32
    /// Height of NavBar for Small state. Usually it's just 44
    static let NavBarHeightSmallState: CGFloat = 44
    /// Height of NavBar for Large state. Usually it's just 96.5 but if you have a custom font for the title, please make sure to edit this value since it changes the height for Large state of NavBar
    static let NavBarHeightLargeState: CGFloat = 96.5
}
