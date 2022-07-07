//
//  EventHandler.swift
//  Runner
//
//  Created by Deepanshu on 20/01/22.
//

import Foundation
import os
import CourierCore
import CourierMQTT

final class EventHandler: ICourierEventHandler {
    
    private let handler: (Dictionary<String, Any>) -> Void
    
    init(handler: @escaping (Dictionary<String, Any>) -> Void) {
        self.handler = handler
    }
    
    func reset() {
        
    }
    
    func onEvent(_ event: CourierEvent) {
        handleCourierEvent(event)
    }
    
    private func handleCourierEvent(_ event: CourierEvent) {
        var eventMap = Dictionary<String, Any>()
        switch event {
        case .connectionDisconnect:
            os_log("Courier event: connectionDisconnect event")
            eventMap["name"] = "Mqtt Disconnect"
        case .connectionAttempt:
            os_log("Courier event: connectionAttempt event")
            eventMap["name"] = "Mqtt Connect Attempt"
        case .connectionSuccess:
            os_log("Courier event: connectionSuccess event")
            eventMap["name"] = "Mqtt Connect Success"
        case .connectionFailure(let error):
            os_log("Courier event: connectionFailure event")
            eventMap["name"] = "Mqtt Connect Failure"
            eventMap["properties"] = ["reason": (error as? NSError)?.code ?? 0]
        case .connectionLost(let error, _, _):
            os_log("Courier event: connectionLost event")
            eventMap["name"] = "Mqtt Connection Lost"
            eventMap["properties"] = ["reason": (error as? NSError)?.code ?? 0]
        case .ping:
            os_log("Courier event: ping event")
            eventMap["name"] = "Mqtt Ping Initiated"
        case .pongReceived:
            os_log("Courier event: pongReceived event")
            eventMap["name"] = "Mqtt Ping Success"
        case .pingFailure(_, let error):
            os_log("Courier event: pingFailure event")
            eventMap["name"] = "Mqtt Ping Failure"
            eventMap["properties"] = ["reason": (error as? NSError)?.code ?? 0]
        case .subscribeAttempt(let topic):
            os_log("Courier event: subscribeAttempt event")
            eventMap["name"] = "Mqtt Subscribe Attempt"
            eventMap["properties"] = ["topic": topic]
        case .subscribeSuccess(let topic):
            os_log("Courier event: subscribeSuccess event")
            eventMap["name"] = "Mqtt Subscribe Success"
            eventMap["properties"] = ["topic": topic]
        case let .subscribeFailure(topic, error):
            os_log("Courier event: subscribeFailure event")
            eventMap["name"] = "Mqtt Subscribe Failure"
            eventMap["properties"] = ["topic": topic, "reason": (error as? NSError)?.code ?? 0]
        case .unsubscribeAttempt(let topic):
            os_log("Courier event: unsubscribeAttempt event")
            eventMap["name"] = "Mqtt Unsubscribe Attempt"
            eventMap["properties"] = ["topic": topic]
        case .unsubscribeSuccess(let topic):
            os_log("Courier event: unsubscribeSuccess event")
            eventMap["name"] = "Mqtt Unsubscribe Success"
            eventMap["properties"] = ["topic": topic]
        case let .unsubscribeFailure(topic, error):
            os_log("Courier event: unsubscribeFailure event")
            eventMap["name"] = "Mqtt Unsubscribe Failure"
            eventMap["properties"] = ["topic": topic, "reason": (error as? NSError)?.code ?? 0]
        case .messageReceive(let topic, _):
            os_log("Courier event: messageReceive event")
            eventMap["name"] = "Mqtt Message Receive"
            eventMap["properties"] = ["topic": topic]
        case let .messageReceiveFailure(topic, error, _):
            os_log("Courier event: messageReceiveFailure event")
            eventMap["name"] = "Mqtt Message Receive Failure"
            eventMap["properties"] = ["topic": topic, "reason": (error as? NSError)?.code ?? 0]
        case .messageSend(let topic, _, _):
            os_log("Courier event: messageSend event")
            eventMap["name"] = "Mqtt Message Send Attempt"
            eventMap["properties"] = ["topic": topic]
        case .messageSendSuccess(let topic, _, _):
            os_log("Courier event: messageSendSuccess event")
            eventMap["name"] = "Mqtt Message Send Success"
            eventMap["properties"] = ["topic": topic]
        case let .messageSendFailure(topic, _, error, _):
            os_log("Courier event: messageSendFailure event")
            eventMap["name"] = "Mqtt Message Send Failure"
            eventMap["properties"] = ["topic": topic, "reason": (error as? NSError)?.code ?? 0]
        default:
            os_log("Courier event: Unhandled event")
        }
        handler(eventMap)
    }
}

