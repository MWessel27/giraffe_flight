//
//  HomeTableViewCell.swift
//  Flawless
//
//  Created by Mikalangelo Wessel on 6/30/19.
//  Copyright © 2019 giraffeflight. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var cellSelectedImage: UIImageView!
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var productDetailTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        // Configure the view for the selected state
//    }
    
}
