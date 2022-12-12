//
//  EventHandler.swift
//  Runner
//
//  Created by Deepanshu on 20/01/22.
//

import CourierCore
import CourierMQTT
import Foundation
import os

final class EventHandler: ICourierEventHandler {
    
    private let handler: (Dictionary<String, Any>) -> Void
    
    init(handler: @escaping (Dictionary<String, Any>) -> Void) {
        self.handler = handler
    }
        
    func onEvent(_ event: CourierEvent) {
        handleCourierEvent(event)
    }
    
    private func handleCourierEvent(_ event: CourierEvent) {
        var eventMap = Dictionary<String, Any>()
        switch event.type {
        case .connectedPacketSent:
            os_log("Courier event: Connect Packet Send event")
            eventMap["name"] = "Connect Packet Send"
    
        case let .courierDisconnect(clearState):
            os_log("Courier event: Courier Disconnect event")
            eventMap["name"] = "Courier Disconnect"
            eventMap["properties"] = ["ClearState": clearState]

        case .connectionAttempt:
            os_log("Courier event: connectionAttempt event")
            eventMap["name"] = "Mqtt Connect Attempt"
        
        case let .connectionSuccess(timeTaken):
            os_log("Courier event: connectionSuccess event")
            eventMap["name"] = "Mqtt Connect Success"
            eventMap["properties"] = ["timeTaken": timeTaken]
        
        case let .connectionFailure(timeTaken, error):
            os_log("Courier event: connectionFailure event")
            eventMap["name"] = "Mqtt Connect Failure"
            eventMap["properties"] = [
                "reason": (error as? NSError)?.code ?? 0,
                "timeTaken": timeTaken
            ]
            
        case let .connectionLost(timeTaken, error, _, _):
            os_log("Courier event: connectionLost event")
            eventMap["name"] = "Mqtt Connection Lost"
            eventMap["properties"] = [
                "reason": (error as? NSError)?.code ?? 0,
                "timeTaken": timeTaken
            ]
            
        case .connectionDisconnect:
            os_log("Courier event: connectionDisconnect event")
            eventMap["name"] = "Mqtt Disconnect"
            
        case .reconnect:
            os_log("Courier event: Courier Reconnect event")
            eventMap["name"] = "Courier Reconnect"
            
        case let .connectDiscarded(reason):
            eventMap["name"] = "Mqtt Connect Discarded"
            eventMap["properties"] = ["reason": reason]
            
        case let .subscribeAttempt(topics):
            os_log("Courier event: subscribeAttempt event")
            topics.forEach { topic in
                var eventMap = [String: Any]()
                eventMap["name"] = "Mqtt Subscribe Attempt"
                eventMap["properties"] = ["topic": topic]
                injectConnectionInfoAndSendEvent(eventMap: eventMap, event: event)
            }
            return
            
        case let .unsubscribeAttempt(topics):
            os_log("Courier event: unsubscribeAttempt event")
            topics.forEach { topic in
                var eventMap = [String: Any]()
                eventMap["name"] = "Mqtt Unsubscribe Attempt"
                eventMap["properties"] = ["topic": topic]
                injectConnectionInfoAndSendEvent(eventMap: eventMap, event: event)
            }
            return
            
        case let .subscribeSuccess(topics, timeTaken):
            os_log("Courier event: subscribeSuccess event")
            topics.forEach { topic in
                var eventMap = [String: Any]()
                eventMap["name"] = "Mqtt Subscribe Success"
                eventMap["properties"] = [
                    "topic": topic.topic,
                    "qos": topic.qos.rawValue,
                    "timeTaken": timeTaken
                ]
                injectConnectionInfoAndSendEvent(eventMap: eventMap, event: event)
            }
            return
            
        case let .unsubscribeSuccess(topics, timeTaken):
            os_log("Courier event: unsubscribeSuccess event")
            topics.forEach { topic in
                var eventMap = [String: Any]()
                eventMap["name"] = "Mqtt Unsubscribe Success"
                eventMap["properties"] = [
                    "topic": topic,
                    "timeTaken": timeTaken
                ]
                injectConnectionInfoAndSendEvent(eventMap: eventMap, event: event)
            }
            return
                        
        case let .subscribeFailure(topics, timeTaken, error):
            os_log("Courier event: subscribeFailure event")
            topics.forEach { topic in
                var eventMap = [String: Any]()
                eventMap["name"] = "Mqtt Subscribe Failure"
                eventMap["properties"] = [
                    "topic": topic.topic,
                    "qos": topic.qos.rawValue,
                    "timeTaken": timeTaken,
                    "reason": (error as? NSError)?.code ?? 0
                ]
                injectConnectionInfoAndSendEvent(eventMap: eventMap, event: event)
            }
            return
            
        case let .unsubscribeFailure(topics, timeTaken, error):
            os_log("Courier event: unsubscribeFailure event")
            topics.forEach { topic in
                var eventMap = [String: Any]()
                eventMap["name"] = "Mqtt Unsubscribe Failure"
                eventMap["properties"] = [
                    "topic": topic,
                    "timeTaken": timeTaken,
                    "reason": (error as? NSError)?.code ?? 0
                ]
                injectConnectionInfoAndSendEvent(eventMap: eventMap, event: event)
            }
            return
        
        case .ping:
            os_log("Courier event: ping event")
            eventMap["name"] = "Mqtt Ping Initiated"
            
        case let .pongReceived(timeTaken):
            os_log("Courier event: pongReceived event")
            eventMap["name"] = "Mqtt Ping Success"
            eventMap["properties"] = ["timeTaken": timeTaken]
            
        case let .pingFailure(timeTaken, error):
            os_log("Courier event: pingFailure event")
            eventMap["name"] = "Mqtt Ping Failure"
            eventMap["properties"] = [
                "timeTaken": timeTaken,
                "reason": (error as? NSError)?.code ?? 0
            ]
        
        case let .messageReceive(topic, sizeBytes):
            os_log("Courier event: messageReceive event")
            eventMap["name"] = "Mqtt Message Receive"
            eventMap["properties"] = [
                "topic": topic,
                "sizeBytes": sizeBytes
            ]
        case let .messageReceiveFailure(topic, error, sizeBytes):
            os_log("Courier event: messageReceiveFailure event")
            eventMap["name"] = "Mqtt Message Receive Failure"
            eventMap["properties"] = [
                "topic": topic,
                "reason": (error as? NSError)?.code ?? 0,
                "sizeBytets": sizeBytes
            ]
        case let .messageSend(topic, qos, sizeBytes):
            os_log("Courier event: messageSend event")
            eventMap["name"] = "Mqtt Message Send Attempt"
            eventMap["properties"] = [
                "topic": topic,
                "qos": qos.rawValue,
                "sizeBytes": sizeBytes
            ]
        case let .messageSendSuccess(topic, qos, sizeBytes):
            os_log("Courier event: messageSendSuccess event")
            eventMap["name"] = "Mqtt Message Send Success"
            eventMap["properties"] = [
                "topic": topic,
                "qos": qos.rawValue,
                "sizeBytes": sizeBytes
            ]
        case let .messageSendFailure(topic, qos, error, sizeBytes):
            os_log("Courier event: messageSendFailure event")
            eventMap["name"] = "Mqtt Message Send Failure"
            eventMap["properties"] = [
                "topic": topic,
                "qos": qos.rawValue,
                "reason": (error as? NSError)?.code ?? 0,
                "sizeBytes": sizeBytes
            ]
        default:
            os_log("Courier event: Unhandled event")
        }
        injectConnectionInfoAndSendEvent(eventMap: eventMap, event: event)
    }
    
    private func injectConnectionInfoAndSendEvent(eventMap: [String: Any], event: CourierEvent) {
        if var props = eventMap["properties"] as? [String: Any],
           let connectionInfo =
            event.connectionInfo {
            props["connectionInfo"] = [
                "host": connectionInfo.host,
                "port": Int(connectionInfo.port),
                "keepAlive": Int(connectionInfo.keepAlive),
                "clientId": connectionInfo.clientId,
                "username": connectionInfo.username
            ]
            var eventMap = eventMap
            eventMap["properties"] = props
            handler(eventMap)
        } else {
            handler(eventMap)
        }
    }
    
    func reset() {}
}

