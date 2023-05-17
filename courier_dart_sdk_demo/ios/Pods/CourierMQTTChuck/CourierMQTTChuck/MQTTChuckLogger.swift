//
//  MQTTChuckLogger.swift
//  CourierE2EApp
//
//  Created by Alfian Losari on 10/04/23.
//

import Foundation
import CourierCore
import CourierMQTT
import MQTTClientGJ

public protocol MQTTChuckLoggerDelegate {
    func mqttChuckLoggerDidUpdateLogs(_ logs: [MQTTChuckLog])
}

public class MQTTChuckLogger {
    
    public private(set) var logs = [MQTTChuckLog]()
    public var delegate: MQTTChuckLoggerDelegate?
    public var dataStringParser: ((Data) -> String?)?
    public var logsMaxSize = 250
    
    public init() {
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMQTTChuckNotification), name: mqttChuckNotification, object: nil)
        CourierMQTTChuck.isEnabled = true
    }
        
    @objc func didReceiveMQTTChuckNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let rawType = userInfo["type"] as? UInt8,
              let type = MQTTCommandType(rawValue: rawType),
              let rawQoS = userInfo["qos"] as? UInt8,
              let qos = QoS(rawValue: Int(rawQoS)),
              let dup = userInfo["duped"] as? Bool,
              let retained = userInfo["retained"] as? Bool,
              let mid = userInfo["mid"] as? UInt16,
              let sending = userInfo["sending"] as? Bool,
              let received = userInfo["received"] as? Bool
        else {
            return
        }
        
        let data = userInfo["data"] as? Data
        var dataString: String?
        
        if let data = data {
            if let dataStringParser = dataStringParser,
               let string = dataStringParser(data) {
                dataString = string
            } else if let string = String(data: data, encoding: .utf8) {
                dataString = string
            } else {
                dataString = (data as NSData).description
            }
        }
        
        let log = MQTTChuckLog(
            commandType: type.debugDescription,
            qos: "\(qos)",
            messageId: Int(mid),
            sending: sending, received: received,
            dup: dup, retained: retained,
            dataLength: data?.count,
            dataString: dataString)
        
        logs.append(log)
        if logs.count >= logsMaxSize {
            logs.removeFirst(10)
        }
        delegate?.mqttChuckLoggerDidUpdateLogs(logs)
    }
    
    public func clearLogs() {
        self.logs = []
        delegate?.mqttChuckLoggerDidUpdateLogs(logs)
    }
    
    deinit {
        CourierMQTTChuck.isEnabled = false
    }
    
}
