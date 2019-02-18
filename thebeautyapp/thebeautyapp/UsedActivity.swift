//
//  usedActivity.swift
//  thebeautyapp
//
//  Created by Mikalangelo Wessel on 2/17/19.
//  Copyright © 2019 giraffeflight. All rights reserved.
//

import UIKit
import os.log

class UsedActivity: NSObject, NSCoding {
    
    //MARK: Properties
    var date: String
    var ampm: Int
    var time: String
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("usedActivities")

    struct PropertyKey {
        static let date = "name"
        static let ampm = "ampm"
        static let time = "time"
    }
    
    init?(date: String, ampm: Int, time: String) {
        
        // Initialization should fail if ampm is greater than 2 or less than 0
        guard (ampm >= 0) && (ampm <= 3) else {
            return nil
        }
        
        self.date = date
        self.ampm = ampm
        self.time = time
    }
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(date, forKey: PropertyKey.date)
        aCoder.encode(ampm, forKey: PropertyKey.ampm)
        aCoder.encode(time, forKey: PropertyKey.time)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        // The date is required. If we cannot decode a date string, the initializer should fail.
        guard let date = aDecoder.decodeObject(forKey: PropertyKey.date) as? String else {
            os_log("Unable to decode the date for usedActivity object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let time = aDecoder.decodeObject(forKey: PropertyKey.time) as? String else {
            os_log("Unable to decode the time for usedActivity object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        let ampm = aDecoder.decodeInteger(forKey: PropertyKey.ampm)
        
        // Must call designated initializer.
        self.init(date: date, ampm: ampm, time: time)
    }
}
