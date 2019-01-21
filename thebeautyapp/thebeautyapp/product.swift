//
//  product.swift
//  thebeautyapp
//
//  Created by Dev on 6/24/18.
//  Copyright © 2018 giraffeflight. All rights reserved.
//

import UIKit
import os.log

class Product: NSObject, NSCoding {
    
    //MARK: Properties
    
    var name: String
    var daily: Bool
    var rating: Int
    var ampm: Int
    var cat: String
    var onSunday: Int
    var onMonday: Int
    var onTuesday: Int
    var onWednesday: Int
    var onThursday: Int
    var onFriday: Int
    var onSaturday: Int
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("products")
    
    //MARK: Types
    
    struct PropertyKey {
        static let name = "name"
        static let daily = "daily"
        static let rating = "rating"
        static let ampm = "ampm"
        static let cat = "cat"
        static let onSunday = "onSunday"
        static let onMonday = "onMonday"
        static let onTuesday = "onTuesday"
        static let onWednesday = "onWednesday"
        static let onThursday = "onThursday"
        static let onFriday = "onFriday"
        static let onSaturday = "onSaturday"
    }
    
    init?(name: String, daily: Bool, rating: Int, ampm: Int, cat: String, onSunday: Int, onMonday: Int, onTuesday: Int, onWednesday: Int, onThursday: Int, onFriday: Int, onSaturday: Int) {
        
        // The name must not be empty
        guard !name.isEmpty else {
            return nil
        }
        
        // The rating must be between 0 and 5 inclusively
        guard (rating >= 0) && (rating <= 5) else {
            return nil
        }
        
        // Initialization should fail if there is no name or if the rating is negative.
        if name.isEmpty || rating < 0  {
            return nil
        }
        
        // Initialization should fail if ampm is greater than 2 or less than 0
        guard (ampm >= 0) && (ampm <= 3) else {
            return nil
        }
        
        self.name = name
        self.daily = daily
        self.rating = rating
        self.ampm = ampm
        self.cat = cat
        self.onSunday = onSunday
        self.onMonday = onMonday
        self.onTuesday = onTuesday
        self.onWednesday = onWednesday
        self.onThursday = onThursday
        self.onFriday = onFriday
        self.onSaturday = onSaturday
    }
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(daily, forKey: PropertyKey.daily)
        aCoder.encode(rating, forKey: PropertyKey.rating)
        aCoder.encode(ampm, forKey: PropertyKey.ampm)
        aCoder.encode(cat, forKey: PropertyKey.cat)
        aCoder.encode(onSunday, forKey: PropertyKey.onSunday)
        aCoder.encode(onMonday, forKey: PropertyKey.onMonday)
        aCoder.encode(onTuesday, forKey: PropertyKey.onTuesday)
        aCoder.encode(onWednesday, forKey: PropertyKey.onWednesday)
        aCoder.encode(onThursday, forKey: PropertyKey.onThursday)
        aCoder.encode(onFriday, forKey: PropertyKey.onFriday)
        aCoder.encode(onSaturday, forKey: PropertyKey.onSaturday)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Product object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        let daily = aDecoder.decodeBool(forKey: PropertyKey.daily)
        
        let rating = aDecoder.decodeInteger(forKey: PropertyKey.rating)
        
        let ampm = aDecoder.decodeInteger(forKey: PropertyKey.ampm)
        
        guard let cat = aDecoder.decodeObject(forKey: PropertyKey.cat) as? String else {
            os_log("Unable to decode the category for a Product object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        let onSunday = aDecoder.decodeInteger(forKey: PropertyKey.onSunday)
        let onMonday = aDecoder.decodeInteger(forKey: PropertyKey.onMonday)
        let onTuesday = aDecoder.decodeInteger(forKey: PropertyKey.onTuesday)
        let onWednesday = aDecoder.decodeInteger(forKey: PropertyKey.onWednesday)
        let onThursday = aDecoder.decodeInteger(forKey: PropertyKey.onThursday)
        let onFriday = aDecoder.decodeInteger(forKey: PropertyKey.onFriday)
        let onSaturday = aDecoder.decodeInteger(forKey: PropertyKey.onSaturday)
        
        // Must call designated initializer.
        self.init(name: name, daily: daily, rating: rating, ampm: ampm, cat: cat, onSunday: onSunday, onMonday: onMonday, onTuesday: onTuesday, onWednesday: onWednesday, onThursday: onThursday, onFriday: onFriday, onSaturday: onSaturday)
    }
}
