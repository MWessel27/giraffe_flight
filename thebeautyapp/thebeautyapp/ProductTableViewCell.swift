//
//  ProductTableViewCell.swift
//  thebeautyapp
//
//  Created by Mikalangelo Wessel on 1/16/19.
//  Copyright © 2019 giraffeflight. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
