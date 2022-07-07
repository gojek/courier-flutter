//
//  MqttClientDelegate.swift
//  Runner
//
//  Created by Deepanshu on 20/01/22.
//

import CourierCore
import CourierMQTT
import Foundation
import os

class CourierClientDelegate {
    private let clientFactory: CourierClientFactory
    private let courierClient: CourierClient
    private let eventHandler: EventHandler
    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()

    init(authService: AuthService,
         eventHandler: EventHandler,
         autoReconnectInterval: UInt16,
         maxAutoReconnectInterval: UInt16,
         connectTimeout: TimeInterval,
         timerInterval: TimeInterval,
         inactivityTimeout: TimeInterval,
         readTimeout: TimeInterval
    ) {
        self.authService = authService
        self.eventHandler = eventHandler
        self.clientFactory = CourierClientFactory()
        self.courierClient = clientFactory.makeMQTTClient(
                    config: MQTTClientConfig(
                        authService: authService,
                        messageAdapters: [
                            DataMessageAdapter()
                        ],
                        isMessagePersistenceEnabled: true,
                        autoReconnectInterval: autoReconnectInterval,
                        maxAutoReconnectInterval: maxAutoReconnectInterval,
                        connectTimeoutPolicy: ConnectTimeoutPolicy(isEnabled: true, timerInterval: connectTimeout, timeout: connectTimeout),
                        idleActivityTimeoutPolicy: IdleActivityTimeoutPolicy(isEnabled: true, timerInterval: timerInterval, inactivityTimeout: inactivityTimeout, readTimeout: readTimeout)
                    )
                )
        self.courierClient.addEventHandler(eventHandler)
    }
    
    func connect(_ connectOptions: ConnectOptions) {
        os_log("Connecting")
        self.authService.setConnectOptions(connectOptions)

        self.courierClient.connect()
    }

    func disconnect(_ clearState: Bool) {
        os_log("Disconnecting")
        if clearState {
            self.courierClient.destroy()
        } else {
            self.courierClient.disconnect()
        }
    }
    
    func subscribe(_ topic: String,_ qos: QoS) {
        os_log("Subscribing")
        self.courierClient.subscribe((topic, qos))
    }
    
    func unsubscribe(_ topic: String) {
        os_log("Unsubscribing")
        self.courierClient.unsubscribe(topic)
    }
    
    func send(_ message: Data, _ topic: String,_ qos: QoS) throws {
        os_log("Sending message")
        do {
            try self.courierClient.publishMessage(message, topic: topic, qos: qos)
        } catch {
            throw error
        }
    }
    
    func receive(listener: @escaping (CourierMessage) -> ()) {
        courierClient.messagePublisher()
            .sink { message in
                let data = message.data
                let topic = message.topic
                listener(CourierMessage(data: data, topic: topic))
            }
            .store(in: &cancellables)
    }
}
