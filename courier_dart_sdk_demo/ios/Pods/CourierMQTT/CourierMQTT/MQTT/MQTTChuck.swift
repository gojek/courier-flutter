//
//  MQTTChuck.swift
//  CourierMQTT
//
//  Created by Alfian Losari on 10/04/23.
//

import Foundation

public actor CourierMQTTChuck {
    
      public static let shared = CourierMQTTChuck()

       private var _isEnabled = false

       public func setEnabled(_ value: Bool) {
           _isEnabled = value
       }

       public func isEnabled() -> Bool {
           _isEnabled
       }
}
public let mqttChuckNotification = NSNotification.Name("GojekCourierMQTTChuckNotification")
