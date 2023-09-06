//
//  Message+Utils.swift
//  Remote Control
//
//  Created by Danno on 8/23/17.
//  Copyright © 2017 Bridgefy Inc. All rights reserved.
//

import Foundation
import CoreData


extension Message {
        
    var date: Date {
        get {
            return Date(timeIntervalSince1970: self.time)
        }
        set {
            self.time = newValue.timeIntervalSince1970
        }
    }
    
    var textDate: String {
        return self.date.timeAgoString(numericDates: true)
    }
}
