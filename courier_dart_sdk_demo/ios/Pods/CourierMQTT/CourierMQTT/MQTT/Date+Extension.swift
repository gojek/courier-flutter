//
//  Date+Extension.swift
//  CourierMQTT
//
//  Created by Alfian Losari on 24/11/22.
//

import Foundation

extension Date {
    var timeTaken: Int {
        Int((Date().timeIntervalSince1970 - self.timeIntervalSince1970) * 1000)
    }
}

