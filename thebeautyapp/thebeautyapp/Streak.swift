//
//  Streak.swift
//  Flawless
//
//  Created by Mikalangelo Wessel on 8/8/20.
//  Copyright © 2020 giraffeflight. All rights reserved.
//

import UIKit
import os.log

class Streak: NSObject, NSCoding {
    
    //MARK: Properties
    var setToday: Bool
    var streak: Int
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("skinCareRatingStreak")
    
    struct PropertyKey {
        static let setToday = "setToday"
        static let streak = "streak"
    }

    //MARK: Initialization
    init?(setToday: Bool, streak: Int) {
        
        // The streak must be equal or above 0
        guard (streak >= 0) else {
            return nil
        }
        
        // Initialize stored properties.
        self.setToday = setToday
        self.streak = streak
    }
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(setToday, forKey: PropertyKey.setToday)
        aCoder.encode(streak, forKey: PropertyKey.streak)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        // The date is required. If we cannot decode a date string, the initializer should fail.
        let setToday = aDecoder.decodeBool(forKey: PropertyKey.setToday)
        let streak = aDecoder.decodeInteger(forKey: PropertyKey.streak)
        
        // Must call designated initializer.
        self.init(setToday: setToday, streak: streak)
    }
}

