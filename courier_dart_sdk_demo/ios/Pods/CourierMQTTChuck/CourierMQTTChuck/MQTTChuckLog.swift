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
    
    public var isConnectOptionsAvailable: Bool { host != nil && !host!.isEmpty}
    
    public var host: String?
    public var port: Int?
    public var keepAlive: Int?
    public var clientId: String?
    public var isCleanSession: Bool?
    public var userProperties: [String: String]?
    public var alpn: [String]?
    public var scheme: String?
}
