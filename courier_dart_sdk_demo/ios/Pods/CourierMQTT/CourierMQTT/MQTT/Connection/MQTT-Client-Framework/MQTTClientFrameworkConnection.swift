import CourierCore
import Foundation
import MQTTClientGJ

class MQTTClientFrameworkConnection: NSObject, IMQTTConnection {

    var sessionManager: IMQTTClientFrameworkSessionManager!
    private let mqttDispatchQueue = DispatchQueue(label: "com.courier.mqtt.connection")
    private var connectRetryTimePolicy: IConnectRetryTimePolicy {
        connectionConfig.connectRetryTimePolicy
    }
    private var eventHandler: ICourierEventHandler {
        connectionConfig.eventHandler
    }

    private let clientFactory: IMQTTClientFrameworkFactory
    private let persistenceFactory: IMQTTPersistenceFactory
    private let connectionConfig: ConnectionConfig
    private(set) var messageReceiveListener: IMessageReceiveListener?
    private(set) var connectOptions: ConnectOptions?

    private(set) var lastPing: Date?
    private(set) var lastPong: Date?

    var isConnected: Bool { sessionManager?.state == .connected }
    var isConnecting: Bool { sessionManager?.state == .connecting }
    var isDisconnecting: Bool { sessionManager?.state == .closing }
    var isDisconnected: Bool { sessionManager?.state == .closed }

    var hasExistingSession: Bool { sessionManager?.session != nil }

    var serverUri: String? {
        guard let options = connectOptions else {
            return nil
        }
        return options.host + ":" + String(options.port)
    }

    private(set) var keepAliveFailureHandler: KeepAliveFailureHandler?

    private var session: IMQTTSession? { sessionManager.session }

    init(connectionConfig: ConnectionConfig,
         clientFactory: IMQTTClientFrameworkFactory,
         persistenceFactory: IMQTTPersistenceFactory = MQTTPersistenceFactory()
    ) {
        self.connectionConfig = connectionConfig
        self.clientFactory = clientFactory
        self.persistenceFactory = persistenceFactory
        super.init()

        self.sessionManager = clientFactory.makeSessionManager(
            connectRetryTimePolicy: connectionConfig.connectRetryTimePolicy, persistenceFactory: persistenceFactory,
            dispatchQueue: mqttDispatchQueue,
            delegate: self,
            connectTimeoutPolicy: connectionConfig.connectTimeoutPolicy,
            idleActivityTimeoutPolicy: connectionConfig.idleActivityTimeoutPolicy
        )
    }

    func connect(connectOptions: ConnectOptions, messageReceiveListener: IMessageReceiveListener) {
        if let currentOptions = self.connectOptions,
           currentOptions == connectOptions,
           isConnected || isConnecting {
            return
        }

        self.messageReceiveListener = messageReceiveListener
        self.connectOptions = connectOptions

        let port = Int(connectOptions.port)
        var securityPolicy: MQTTSSLSecurityPolicy?
        if port == 443 {
            securityPolicy = MQTTSSLSecurityPolicy()
            securityPolicy?.allowInvalidCertificates = true
        }

        eventHandler.onEvent(.connectionAttempt)
        sessionManager.connect(
            to: connectOptions.host,
            port: port,
            keepAlive: Int(connectOptions.keepAlive),
            isCleanSession: connectOptions.isCleanSession,
            isAuth: true,
            clientId: connectOptions.clientId,
            username: connectOptions.username,
            password: connectOptions.password,
            lastWill: false,
            lastWillTopic: nil,
            lastWillMessage: nil,
            lastWillQoS: nil,
            lastWillRetainFlag: false,
            securityPolicy: securityPolicy,
            certificates: nil,
            protocolLevel: .version311,
            userProperties: connectOptions.userProperties,
            connectHandler: nil
        )
    }

    func disconnect() {
        sessionManager?.disconnect(with: nil)
        resetParams()
    }

    func publish(packet: MQTTPacket) {
        eventHandler.onEvent(.messageSend(topic: packet.topic, qos: packet.qos, sizeBytes: packet.data.count))
        sessionManager.publish(packet: packet)
    }

    func deleteAllPersistedMessages(clientId: String) {
        let persistence = persistenceFactory.makePersistence()
        persistence.persistent = true
        mqttDispatchQueue.async {
            persistence.deleteAllFlows(forClientId: clientId)
        }
    }

    func subscribe(_ topics: [(topic: String, qos: QoS)]) {
        guard isConnected, !topics.isEmpty else {
            return
        }

        printDebug("MQTT - COURIER: Starting to request subscribe \(topics.map { "\($0.0):\($0.1)" })")
        topics.forEach { topicQos in
            eventHandler.onEvent(.subscribeAttempt(topic: topicQos.topic))
        }
        sessionManager.subscribe(topics)
    }

    func unsubscribe(_ topics: [String]) {
        guard isConnected, !topics.isEmpty else {
            return
        }
        printDebug("MQTT - COURIER: Starting to request unsubscribe \(topics)")
        topics.forEach {
            eventHandler.onEvent(.unsubscribeAttempt(topic: $0))
        }
        sessionManager.unsubscribe(topics)
    }

    func setKeepAliveFailureHandler(handler: KeepAliveFailureHandler) {
        self.keepAliveFailureHandler = handler
    }

    func resetParams() {
        lastPing = nil
        lastPong = nil
    }

}

extension MQTTClientFrameworkConnection: MQTTClientFrameworkSessionManagerDelegate {

    func sessionManager(_ sessionManager: IMQTTClientFrameworkSessionManager, didChangeState newState: MQTTSessionManagerState) {
        switch newState {

        case .starting:
            printDebug("MQTT - COURIER: Connection Starting")

        case .connecting:
            printDebug("MQTT - COURIER: Connecting")
            eventHandler.onEvent(.connectionAttempt)

        case .connected:
            printDebug("MQTT - COURIER: Connected")
            eventHandler.onEvent(.connectionSuccess)

        case .error:
            guard let error = sessionManager.lastError as NSError? else { return }
            printDebug("MQTT - COURIER: Error \(error.localizedDescription)")
            eventHandler.onEvent(.connectionFailure(error: error))

            switch error.code {
            case MQTTSessionError.connackBadUsernameOrPassword.rawValue,
                 MQTTSessionError.connackNotAuthorized.rawValue:
                printDebug("MQTT - COURIER: Auth Failure \(error.code)")
                connectionConfig.authFailureHandler.handleAuthFailure()

            default:
                return
            }

        case .closing:
            printDebug("MQTT - COURIER: Connection Closing")

        case .closed:
            printDebug("MQTT - COURIER: Connection Closed")

            eventHandler.onEvent(.connectionLost(
                                    error: sessionManager.lastError,
                                    diffLastInbound: getLastInboundDiff(),
                                    diffLastOutbound: getLastOutboundDiff())
            )
        @unknown default:
            break
        }
    }

    func sessionManagerDidPing(_ sessionManager: IMQTTClientFrameworkSessionManager) {
        printDebug("MQTT - COURIER: Ping at \(Date())")
        eventHandler.onEvent(.ping(url: serverUri ?? ""))
        if let lastPing = lastPing {
            if (lastPong != nil && lastPing > lastPong!) || lastPong == nil {
                printDebug("MQTT - COURIER: Ping Failure at \(Date()), didn't receive pong since \(lastPing)")
                eventHandler.onEvent(.pingFailure(timeTaken: Int(Date().timeIntervalSince1970 - lastPing.timeIntervalSince1970) * 1000, error: nil))
                keepAliveFailureHandler?.handleKeepAliveFailure()
                return
            }
        }
        lastPing = Date()
    }

    func sessionManagerDidReceivePong(_ sessionManager: IMQTTClientFrameworkSessionManager) {
        lastPong = Date()
        if let lastPing = self.lastPing, let lastPong = self.lastPong {
            printDebug("MQTT - COURIER: Pong received at \(Date()), last ping: \(lastPing)")
            eventHandler.onEvent(.pongReceived(timeTaken: Int(lastPong.timeIntervalSinceNow - lastPing.timeIntervalSinceNow) * 1000))
        }
        lastPing = nil
    }

    func sessionManager(_ sessionManager: IMQTTClientFrameworkSessionManager, didReceiveMessageData data: Data, onTopic topic: String, qos: MQTTQosLevel, retained: Bool, mid: UInt32) {

        #if DEBUG
        if let string = String(data: data, encoding: .utf8) {
            printDebug("MQTT - COURIER: Receive message from topic: \(String(describing: topic)) with payload: \(string)")
        }
        #endif

        eventHandler.onEvent(.messageReceive(topic: topic, sizeBytes: data.count))
        messageReceiveListener?.messageArrived(
            data: data,
            topic: topic,
            qos: QoS(rawValue: Int(qos.rawValue)) ?? .zero
        )
    }

    func sessionManager(_ sessionManager: IMQTTClientFrameworkSessionManager, didDeliverMessageID msgID: UInt16, topic: String, data: Data, qos: MQTTQosLevel, retainFlag: Bool) {
        #if DEBUG
        printDebug("MQTT - COURIER: Message Delivered topic: \(topic), qos: \(qos), payload: \(String(data: data, encoding: .utf8) ?? "")")
        #endif
        eventHandler.onEvent(.messageSendSuccess(topic: topic, qos: QoS(rawValue: Int(qos.rawValue)) ?? .zero, sizeBytes: data.count))
    }

    func sessionManager(_ sessionManager: IMQTTClientFrameworkSessionManager, didSubscribeTopics topics: [String]) {
        topics.forEach { topic in
            printDebug("MQTT - COURIER: Subscribed to \(topic)")
            connectionConfig.eventHandler.onEvent(.subscribeSuccess(topic: topic))
        }
    }

    func sessionManager(_ sessionManager: IMQTTClientFrameworkSessionManager, didUnsubscribeTopics topics: [String]) {
        printDebug("MQTT - COURIER: Unsubscribed from \(topics)")
        topics.forEach {
            eventHandler.onEvent(.unsubscribeSuccess(topic: $0))
        }
    }

    func sessionManager(_ sessionManager: IMQTTClientFrameworkSessionManager, didFailToSubscribeTopics topics: [String], error: Error) {
        printDebug("MQTT - COURIER: Subscribe failed topics: \(topics) \(error.localizedDescription)")
        topics.forEach {
            eventHandler.onEvent(.subscribeFailure(topic: $0, error: error))
        }
    }

    func sessionManager(_ sessionManager: IMQTTClientFrameworkSessionManager, didFailToUnsubscribeTopics topics: [String], error: Error) {
        printDebug("MQTT - COURIER: Unsubscribed failed topics: \(topics) \(error.localizedDescription)")
        topics.forEach {
            eventHandler.onEvent(.unsubscribeFailure(topic: $0, error: error))
        }
    }

    func sessionManagerDidSendConnectPacket(_ sessionManager: IMQTTClientFrameworkSessionManager) {
        eventHandler.onEvent(.connectedPacketSent)
    }

    private func getLastInboundDiff() -> Int? {
        if let lastInbound = session?.lastInboundActivityTimestamp, lastInbound > 0 {
            return Int((Date().timeIntervalSince1970 - lastInbound) * 1000)
        } else {
            return nil
        }
    }

    private func getLastOutboundDiff() -> Int? {
        if let lastOutbound = session?.lastOutboundActivityTimestamp, lastOutbound > 0 {
            return Int((Date().timeIntervalSince1970 - lastOutbound) * 1000)
        } else {
            return nil
        }
    }
}
