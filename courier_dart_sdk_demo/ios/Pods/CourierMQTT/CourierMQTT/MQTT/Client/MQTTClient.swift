import CourierCore
import Foundation
import Reachability

class MQTTClient: IMQTTClient {
    let connection: IMQTTConnection

    @Atomic<ConnectOptions?>(nil) private(set) var connectOptions

    private(set) var isInitialized = false
    private let eventHandler: ICourierEventHandler

    private var messagePublishSubject = PublishSubject<MQTTPacket>()
    private(set) var messageReceiverListener: IMessageReceiveListener

    private let reachability: Reachability?
    private let notificationCenter: NotificationCenter
    private let useAppDidEnterBGAndWillEnterFGNotification: Bool

    var isConnecting: Bool { connection.isConnecting }
    var isConnected: Bool { connection.isConnected }
    var hasExistingSession: Bool { connection.hasExistingSession }

    private let dispatchQueue: DispatchQueue

    var subscribedMessageStream: Observable<MQTTPacket> {
        messagePublishSubject.asObservable()
    }

    init(configuration: IMQTTConfiguration,
         messageReceiveListenerFactory: IMessageReceiveListenerFactory = MessageReceiveListenerFactory(),
         mqttConnectionFactory: IMQTTConnectionFactory,
         reachability: Reachability? = try? Reachability(),
         notificationCenter: NotificationCenter = NotificationCenter.default,
         useAppDidEnterBGAndWillEnterFGNotification: Bool = true,
         dispatchQueue: DispatchQueue = .main) {
        self.reachability = reachability
        self.notificationCenter = notificationCenter
        self.useAppDidEnterBGAndWillEnterFGNotification = useAppDidEnterBGAndWillEnterFGNotification
        self.dispatchQueue = dispatchQueue
        eventHandler = configuration.eventHandler

        messageReceiverListener = messageReceiveListenerFactory.makeListener(
            publishSubject: messagePublishSubject,
            publishSubjectDispatchQueue: DispatchQueue(label: "com.courier.incomingMessage"),
            messagePersistenceTTLSeconds: configuration.messagePersistenceTTLSeconds,
            messageCleanupInterval: configuration.messageCleanupInterval)

        let connectionConfig = ConnectionConfig(
            connectRetryTimePolicy: configuration.connectRetryTimePolicy,
            eventHandler: configuration.eventHandler,
            authFailureHandler: configuration.authFailureHandler,
            connectTimeoutPolicy: configuration.connectTimeoutPolicy,
            idleActivityTimeoutPolicy: configuration.idleActivityTimeoutPolicy,
            isPersistent: configuration.isMQTTPersistentEnabled,
            shouldInitializeCoreDataPersistenceContext: configuration.shouldInitializeCoreDataPersistenceContext
        )

        connection = mqttConnectionFactory.makeConnection(connectionConfig: connectionConfig)
        connection.setKeepAliveFailureHandler(handler: self)
    }

    func setKeepAliveFailureHandler(handler: KeepAliveFailureHandler) {
        connection.setKeepAliveFailureHandler(handler: handler)
    }

    func connect(connectOptions: ConnectOptions) {
        self.connectOptions = connectOptions
        isInitialized = true
        connectMqtt()
    }

    func reconnect() {
        guard let options = self.connectOptions, !isConnected, !isConnecting else {
            return
        }
        eventHandler.onEvent(.init(connectionInfo: options, event: .reconnect))
        disconnect()
        connect(connectOptions: options)
    }

    func disconnect() {
        eventHandler.onEvent(.init(connectionInfo: connectOptions, event: .connectionDisconnect))
        isInitialized = false
        disconnectMqtt()
    }

    func send(packet: MQTTPacket) {
        connection.publish(packet: packet)
    }

    func deleteAllPersistedMessages() {
        connection.deleteAllPersistedMessages()
    }

    func subscribe(_ topics: [(topic: String, qos: QoS)]) {
        connection.subscribe(topics)
    }

    func unsubscribe(_ topics: [String]) {
        connection.unsubscribe(topics)
    }

    private func observeNetwork() {
        guard
            let reachability = self.reachability,
            reachability.whenReachable == nil ||
                reachability.whenUnreachable == nil
        else {
            return
        }

        reachability.whenUnreachable = { [weak self] _ in
            self?.handleConnectionChange()
        }

        reachability.whenReachable = { [weak self] _ in
            self?.handleConnectionChange()
        }

        try? reachability.startNotifier()
    }

    private func removeObserveNetwork() {
        reachability?.whenReachable = nil
        reachability?.whenUnreachable = nil
        reachability?.stopNotifier()
    }

    func handleConnectionChange() {
        if reachability?.connection == .unavailable {
            eventHandler.onEvent(.init(connectionInfo: connectOptions, event: .connectionUnavailable))
            
        } else {
            eventHandler.onEvent(.init(connectionInfo: connectOptions, event: .connectionAvailable))
        }
    }

    private func observeAppLifecycle() {
        if useAppDidEnterBGAndWillEnterFGNotification {
            notificationCenter.addObserver(
                self, selector: #selector(onBackground),
                name: UIApplication.didEnterBackgroundNotification, object: nil
            )
            notificationCenter.addObserver(
                self, selector: #selector(onForeground),
                name: UIApplication.willEnterForegroundNotification, object: nil
            )
        } else {
            notificationCenter.addObserver(
                self, selector: #selector(onBackground),
                name: UIApplication.willResignActiveNotification, object: nil
            )
            notificationCenter.addObserver(
                self, selector: #selector(onForeground),
                name: UIApplication.didBecomeActiveNotification, object: nil
            )
        }
    }

    private func removeObserveAppLifecycle() {
        if useAppDidEnterBGAndWillEnterFGNotification {
            notificationCenter.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
            notificationCenter.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        } else {
            notificationCenter.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
            notificationCenter.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        }
    }

    @objc func onForeground() {
        eventHandler.onEvent(.init(connectionInfo: connectOptions, event: .appForeground))
    }

    @objc func onBackground() {
        eventHandler.onEvent(.init(connectionInfo: connectOptions, event: .appBackground))
    }

    func reset() {
        removeObserveAppLifecycle()
        observeAppLifecycle()

        observeNetwork()
        connection.resetParams()
    }

    func destroy() {
        disconnect()
        connectOptions = nil
        removeObserveAppLifecycle()
        removeObserveNetwork()
    }

    deinit {
        destroy()
        messagePublishSubject.onCompleted()
    }
}

extension MQTTClient {
    private func connectMqtt() {
        guard let options = self.connectOptions, isInitialized else {
            return
        }

        connection.connect(
            connectOptions: options,
            messageReceiveListener: messageReceiverListener
        )
    }

    private func disconnectMqtt() {
        connection.disconnect()
    }

    func handleMqttException(error _: Error?, reconnect _: Bool) {}
}

extension MQTTClient: KeepAliveFailureHandler {
    func handleKeepAliveFailure() {
        disconnect()
        reconnect()
    }
}
