import Flutter
import UIKit
import CourierCore
import os

public class SwiftCourierDartSdkPlugin: NSObject, FlutterPlugin {
    private var courierClientDelegate: CourierClientDelegate!
    private let channel: FlutterMethodChannel

    init(channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "courier", binaryMessenger: registrar.messenger())

        let instance = SwiftCourierDartSdkPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)

        let factory = MQTTChuckViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "mqtt-chuck-view")
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "initialise" {
            initialise(call.arguments as! Dictionary<String, Any>)
            result("initialised")
        } else if call.method == "connect" {
            connect(call.arguments as! Dictionary<String, Any>)
            result("connected")
        } else if call.method == "disconnect" {
            disconnect(call.arguments as! Dictionary<String, Any>)
            result("disconnected")
        } else if call.method == "subscribe" {
            subscribe(call.arguments as! Dictionary<String, Any>)
            result("subscribed")
        } else if call.method == "unsubscribe" {
            unsubscribe(call.arguments as! Dictionary<String, Any>)
            result("unsubscribed")
        } else if call.method == "send" {
            do {
                try sendMessage(call.arguments as! Dictionary<String, Any>)
                result("sent")
            } catch {
                result(error)
            }
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    private func initialise(_ arguments: Dictionary<String, Any>) {
        let eventHandler = EventHandler(handler: {
            (eventMap: Dictionary<String, Any>) -> () in
            self.handleEvent(eventMap)
        })
        let authService = AuthService()
        let autoReconnectInterval = (arguments["connectRetryPolicyConfig"] as! Dictionary<String, Any>)["baseRetryTimeSeconds"] as! UInt16
        let maxAutoReconnectInterval = (arguments["connectRetryPolicyConfig"] as! Dictionary<String, Any>)["maxRetryTimeSeconds"] as! UInt16
        let timerInterval = arguments["activityCheckIntervalSeconds"] as! TimeInterval
        let inactivityTimeout = arguments["inactivityTimeoutSeconds"] as! TimeInterval
        let readTimeout = arguments["readTimeoutSeconds"] as! TimeInterval
        let connectTimeout = (arguments["connectTimeoutConfig"] as! Dictionary<String, Any>)["socketTimeout"] as! TimeInterval
        self.courierClientDelegate = CourierClientDelegate(
            authService: authService,
            eventHandler: eventHandler,
            autoReconnectInterval: autoReconnectInterval,
            maxAutoReconnectInterval: maxAutoReconnectInterval,
            connectTimeout: connectTimeout,
            timerInterval: timerInterval,
            inactivityTimeout: inactivityTimeout,
            readTimeout: readTimeout
        )

        authService.methodChannelGetConnectOptionsHandler = {
            self.handleAuthFailure()
        }
        courierClientDelegate.receive(listener: {
            (message: CourierMessage) -> () in
            self.handleMessageReceive(message)
        })
    }

    private func connect(_ arguments: Dictionary<String, Any>) {
        let connectOptions = ConnectOptions(
            host: arguments["host"] as! String,
            port: arguments["port"] as! UInt16,
            keepAlive: arguments["keepAliveSeconds"] as! UInt16,
            clientId: arguments["clientId"] as! String,
            username: arguments["username"] as! String,
            password: arguments["password"] as! String,
            isCleanSession: arguments["cleanSession"] as! Bool
        )
        self.courierClientDelegate.connect(connectOptions)
    }

    private func disconnect(_ arguments: Dictionary<String, Any>) {
        let clearState = arguments["clearState"] as! Bool
        self.courierClientDelegate.disconnect(clearState)
    }

    private func subscribe(_ arguments: Dictionary<String, Any>) {
        let topic = arguments["topic"] as! String
        let qos = arguments["qos"] as! Int
        self.courierClientDelegate.subscribe(topic, getQoS(qos))
    }

    private func unsubscribe(_ arguments: Dictionary<String, Any>) {
        let topic = arguments["topic"] as! String
        self.courierClientDelegate.unsubscribe(topic)
    }

    private func sendMessage(_ arguments: Dictionary<String, Any>) throws {
        let message = (arguments["message"] as! FlutterStandardTypedData).data
        let topic = arguments["topic"] as! String
        let qos = arguments["qos"] as! Int
        do {
            try self.courierClientDelegate.send(message, topic, getQoS(qos))
        } catch {
            throw error
        }

    }

    private func handleMessageReceive(_ message: CourierMessage) {
        var arguments = Dictionary<String, Any>()
        let data = FlutterStandardTypedData(bytes: message.data)
        arguments["message"] = data
        arguments["topic"] = message.topic
        DispatchQueue.main.async {
            self.channel.invokeMethod("onMessageReceive", arguments: arguments, result: {(r:Any?) -> () in
              os_log("onMessageReceive method result")
            })
        }
    }

    private func handleAuthFailure() {
        DispatchQueue.main.async {
            os_log("handle auth failure")
            self.channel.invokeMethod("onAuthFailure", arguments: nil, result: {(r:Any?) -> () in
                os_log("onAuthFailure method result ")
            })
        }
    }

    private func handleEvent(_ eventMap: Dictionary<String, Any>) {
        DispatchQueue.main.async {
            self.channel.invokeMethod("handleEvent", arguments: eventMap, result: {(r:Any?) -> () in
                os_log("handleEvent method result ")
            })
        }
    }

    private func getQoS(_ qos: Int) -> QoS {
        if qos < 1 {
            return QoS.zero
        } else if qos == 1 {
            return QoS.one
        } else {
            return QoS.two
        }
    }
}
