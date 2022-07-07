//
//  MessageListener.swift
//  Runner
//
//  Created by Deepanshu on 25/01/22.
//

import Foundation

protocol MessageListener {
    func onMessageReceive(message: [UInt8], topic: String)
}
