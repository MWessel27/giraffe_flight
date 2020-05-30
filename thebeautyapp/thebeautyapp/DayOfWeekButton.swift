//
//  DayOfWeekButton.swift
//  Flawless
//
//  Created by Mikalangelo Wessel on 5/30/20.
//  Copyright © 2020 giraffeflight. All rights reserved.
//

import UIKit

class DayOfWeekButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.setBackgroundColor(color: UIColor.black, forState: .selected)
        self.setTitleColor(UIColor.white, for: .selected)
        self.layer.cornerRadius = 10
        if(self.isSelected) {
            self.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.bold)
        }
    }
    
    
    
}
