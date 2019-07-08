//
//  Rating.swift
//  Flawless
//
//  Created by Mikalangelo Wessel on 7/7/19.
//  Copyright © 2019 giraffeflight. All rights reserved.
//

import UIKit
import os.log

class Rating: NSObject, NSCoding {
    
    //MARK: Properties
    var date: String
    var rating: Int
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("skinCareRating")
    
    struct PropertyKey {
        static let date = "date"
        static let rating = "rating"
    }

    //MARK: Initialization
    init?(date: String, rating: Int) {
        // The date must not be empty
        guard !date.isEmpty else {
            return nil
        }
        
        // The rating must be between 0 and 5 inclusively
        guard (rating >= 0) && (rating <= 5) else {
            return nil
        }
        
        // Initialize stored properties.
        self.date = date
        self.rating = rating
    }
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(date, forKey: PropertyKey.date)
        aCoder.encode(rating, forKey: PropertyKey.rating)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        // The date is required. If we cannot decode a date string, the initializer should fail.
        guard let date = aDecoder.decodeObject(forKey: PropertyKey.date) as? String else {
            os_log("Unable to decode the date for rating object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        let rating = aDecoder.decodeInteger(forKey: PropertyKey.rating)
        
        // Must call designated initializer.
        self.init(date: date, rating: rating)
    }
}
