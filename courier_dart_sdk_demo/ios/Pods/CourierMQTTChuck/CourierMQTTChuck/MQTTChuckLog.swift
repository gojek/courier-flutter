//
//  MQTTChuckLog.swift
//  CourierE2EApp
//
//  Created by Alfian Losari on 10/04/23.
//

import Foundation

public struct MQTTChuckLog: Identifiable {
    
    public let id = UUID()
    
    public let commandType: String
    public let qos: String
    public let messageId: Int
    public let sending: Bool
    public let received: Bool
    
    public let dup: Bool
    public let retained: Bool
    public let dataLength: Int?
    public let dataString: String?
    
    public let timestamp = Date()
}
