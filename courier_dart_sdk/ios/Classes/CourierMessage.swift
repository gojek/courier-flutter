//
//  CourierMessage.swift
//  Runner
//
//  Created by Deepanshu on 25/01/22.
//

import Foundation

class CourierMessage {
    final let data: Data
    final let topic: String
    
    init(data: Data, topic: String) {
        self.data = data
        self.topic = topic
    }
}
