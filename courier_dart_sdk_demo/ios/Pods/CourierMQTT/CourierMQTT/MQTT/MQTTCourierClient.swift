import CourierCore
import Reachability
import UIKit
import MQTTClientGJ

/// Marked this class as `@unchecked Sendable` because it contains properties like `DispatchQueue`,
/// `PublishSubject`, and other reference types that are not `Sendable` by default.
/// However, all non-Sendable properties are accessed in a thread-safe and controlled manner (e.g., via `@Atomic` or internal dispatching),
/// so manual conformance is safe in this context.
class MQTTCourierClient: CourierClient, @unchecked Sendable {
    var client: IMQTTClient!
    private let connectionSubject = PublishSubject<ConnectionState>()
    let subscriptionStore: ISubscriptionStore
    let messageAdaptersCoordinator: MessageAdaptersCoordinator
    let courierEventHandler: IMulticastCourierEventHandler
    let connectionServiceProvider: IConnectionServiceProvider
    let config: MQTTClientConfig
    private let authRetryPolicy: IAuthRetryPolicy
    let dispatchQueue = DispatchQueue(label: "courier.mqtt.queue", qos: .default)
    private var authFailureReconnectTimer: ReconnectTimer?
    var backgroundTaskID: UIBackgroundTaskIdentifier?
    
    @Atomic<String?>(nil) private(set) var connectSource
    @Atomic<Bool>(false) private(set) var isAuthenticating
    @Atomic<ReconnectTimer?>(nil) private(set) var authenticationTimeoutTimer
    @Atomic<Bool>(false) private(set) var isDestroyed
    @Atomic<Date>(Date()) private(set) var authStartTimestamp

    var connectionState: ConnectionState {
        ConnectionState(client: client)
    }
    
    var connectionStatePublisher: AnyPublisher<ConnectionState, Never> {
        PassthroughSubject(observable: connectionSubject.asObservable())
    }
    
    var hasExistingSession: Bool {
        client.hasExistingSession
    }
    
    convenience init(config: MQTTClientConfig) {
        self.init(
            config: config,
            mqttClientFactory: MQTTClientFactory()
        )
    }

    init(config: MQTTClientConfig,
         subscriptionStoreFactory: ISubscriptionStoreFactory = SubscriptionStoreFactory(),
         multicastEventHandlerFactory: IMulticastCourierEventHandlerFactory = MulticastCourierEventHandlerFactory(),
         mqttClientFactory: IMQTTClientFactory = MQTTClientFactory(),
         authRetryPolicy: IAuthRetryPolicy = AuthRetryPolicy()) {

        self.config = config
        self.connectionServiceProvider = config.authService
        self.authRetryPolicy = authRetryPolicy
        self.messageAdaptersCoordinator = MessageAdaptersCoordinator(messageAdapters: config.messageAdapters)
        self.subscriptionStore = subscriptionStoreFactory.makeStore(
            topics: config.topics
        )

        let courierEventHandler = multicastEventHandlerFactory.makeHandler()
        self.courierEventHandler = courierEventHandler

        let configuration = MQTTConfiguration(
            connectRetryTimePolicy: ConnectRetryTimePolicy(autoReconnectInterval: config.autoReconnectInterval, maxAutoReconnectInterval: config.maxAutoReconnectInterval),
            connectTimeoutPolicy: config.connectTimeoutPolicy,
            idleActivityTimeoutPolicy: config.idleActivityTimeoutPolicy,
            authFailureHandler: self,
            eventHandler: courierEventHandler,
            messagePersistenceTTLSeconds: config.messagePersistenceTTLSeconds,
            messageCleanupInterval: config.messageCleanupInterval,
            isMQTTPersistentEnabled: config.isMessagePersistenceEnabled,
            isMQTTMemoryPersistentEnabled: config.isMessageInMemoryPersistenceEnabled)

        let reachability = try? Reachability()
        self.client = mqttClientFactory.makeClient(configuration: configuration, reachability: reachability, dispatchQueue: dispatchQueue)
        courierEventHandler.addEventHandler(self)

        self.authFailureReconnectTimer = ReconnectTimer(retryInterval: TimeInterval(config.autoReconnectInterval), maxRetryInterval: TimeInterval(config.maxAutoReconnectInterval), queue: dispatchQueue) { [weak self] in
            self?.handleAuthFailure()
        }
    }

    func connect() {
        let connectionState = self.connectionState
        switch connectionState {
        case .connecting, .connected:
            courierEventHandler.onEvent(.init(connectionInfo: client.connectOptions, event: .connectDiscarded(reason: connectionState.discardedReason ?? "")))
            return
        case .disconnected:
            guard !self.isAuthenticating else {
                courierEventHandler.onEvent(.init(connectionInfo: client.connectOptions, event: .connectDiscarded(reason: "Client is authenticating")))
                return
            }
        @unknown default:
            break
        }
        
        authStartTimestamp = Date()
        courierEventHandler.onEvent(.init(connectionInfo: client.connectOptions, event: .connectionServiceAuthStart))
        isAuthenticating = true
        isDestroyed = false

        if config.enableAuthenticationTimeout {
            authenticationTimeoutTimer?.stop()
            let isGettingConnectOptionsCompleted = BoolActor(false)

            authenticationTimeoutTimer = ReconnectTimer(retryInterval: config.authenticationTimeoutInterval, maxRetryInterval: config.authenticationTimeoutInterval, queue: dispatchQueue) { [weak self] in
                Task(priority: .background) { [weak self] in
                      guard let self = self else { return }

                      let completed = await isGettingConnectOptionsCompleted.get()
                      guard !completed else { return }

                      self.isAuthenticating = false
                      self.connect()
                  }
            }
            authenticationTimeoutTimer?.schedule()

            self.connectionServiceProvider.getConnectOptions { [weak self] result in
                self?.dispatchQueue.async { [weak self] in
                    guard let self = self else { return }
                    Task(priority: .background) { [weak self] in
                        guard let self = self else { return }
                        await isGettingConnectOptionsCompleted.set(true)
                    }
                    self.authenticationTimeoutTimer?.stop()
                    self.authenticationTimeoutTimer = nil
                    self.isAuthenticating = false
                    if self.isDestroyed {
                        self.courierEventHandler.onEvent(.init(connectionInfo: self.client.connectOptions, event: .connectDiscarded(reason: "Courier client is destroyed")))
                        return
                    }
                    self.handleAuthenticationResult(result)
                }
            }
        } else {
            connectionServiceProvider.getConnectOptions { [weak self] result in
                self?.dispatchQueue.async {[weak self] in
                    self?.isAuthenticating = false
                    self?.handleAuthenticationResult(result)
                }
            }
        }
    }

    func connect(source: String) {
        self.connectSource = source
        self.connect()
    }

    private func handleAuthenticationResult(_ result: Result<ConnectOptions, AuthError>) {
        switch result {
        case let .success(connectOptions):
            courierEventHandler.onEvent(.init(connectionInfo: client.connectOptions, event: .connectionServiceAuthSuccess(timeTaken: self.authStartTimestamp.timeTaken)))
       
            authRetryPolicy.resetParams()
            authFailureReconnectTimer?.resetRetryInterval()
            client.reset()
            client.connect(connectOptions: connectOptions)

        case let .failure(error):
            let nsError = error.asNSError()
            courierEventHandler.onEvent(.init(connectionInfo: client.connectOptions, event: .connectionServiceAuthFailure(timeTaken: self.authStartTimestamp.timeTaken, error: nsError)))
            let networkErrors = [NSURLErrorNetworkConnectionLost, NSURLErrorNotConnectedToInternet]
            if nsError.domain == NSURLErrorDomain, networkErrors.contains(nsError.code) {
                courierEventHandler.onEvent(.init(connectionInfo: client.connectOptions, event: .connectionUnavailable))
            }

            if authRetryPolicy.shouldRetry(error: error) {
                dispatchQueue.asyncAfter(deadline: .now() + authRetryPolicy.getRetryTime()) { [weak self] in
                    self?.handleAuthFailure()
                }
            } else {
                self.authFailureReconnectTimer?.schedule()
            }
        }
    }

    func messagePublisher<D>(topic: String) -> AnyPublisher<D, Never> {
        printSubscribeDebug(topic: topic)

        let observable: Observable<D> = client.subscribedMessageStream
            .filter { $0.topic == topic }
            .compactMap { [weak self] packet in
                guard let self = self else { return nil }
                if let message: D = self.messageAdaptersCoordinator.decodeMessage(packet.data, topic: topic) {
                    return message
                }
                self.courierEventHandler.onEvent(.init(connectionInfo: self.client.connectOptions, event: .messageReceiveFailure(topic: topic, error: CourierError.decodingError.asNSError, sizeBytes: packet.data.count)))
                return nil
            }
        return PassthroughSubject(observable: observable,
                                  sinkInitiated: self.generateSinkInitiatedClosure(topic: topic),
                                  sinkCancelled: self.generateSinkCancelledClosure(topic: topic))
    }

    func messagePublisher<D, E>(topic: String, errorDecodeHandler: @escaping ((E) -> Error)) -> AnyPublisher<Result<D, NSError>, Never> {
        printSubscribeDebug(topic: topic)

        let observable: Observable<Result<D, NSError>> = client
            .subscribedMessageStream
            .filter { $0.topic == topic }
            .compactMap { [weak self] (packet) -> Result<D, NSError>? in
                guard let self = self else { return nil }
                if let model: D = self.messageAdaptersCoordinator.decodeMessage(packet.data, topic: topic) {
                    return .success(model)
                } else if let decodedError: E = self.messageAdaptersCoordinator.decodeMessage(packet.data, topic: topic) {
                    return .failure(errorDecodeHandler(decodedError) as NSError)
                } else {
                    self.courierEventHandler.onEvent(.init(connectionInfo: self.client.connectOptions, event: .messageReceiveFailure(topic: topic, error: CourierError.decodingError.asNSError, sizeBytes: packet.data.count)))
                    return nil
                }
            }
        return PassthroughSubject(observable: observable,
                                  sinkInitiated: self.generateSinkInitiatedClosure(topic: topic),
                                  sinkCancelled: self.generateSinkCancelledClosure(topic: topic))
    }

    func messagePublisher() -> AnyPublisher<Message, Never> {
        let observable: Observable<Message> = client.subscribedMessageStream
            .map { Message(data: $0.data, topic: $0.topic, qos: $0.qos) }
        return PassthroughSubject(observable: observable,
                                  sinkInitiated: { [weak self] in self?.client.messageReceiverListener.handlePersistedMessages() }
        )
    }

    func publishMessage<E>(_ data: E, topic: String, qos: QoS) throws {
        guard client.hasExistingSession else {
            throw CourierError.sessionNotExist.asNSError
        }

        do {
            let data = try messageAdaptersCoordinator.encodeMessage(data, topic: topic)
            printDebug("COURIER Publish - topic:\(topic), payload: \(String(data: data, encoding: .utf8) ?? "")")
            client.send(packet: MQTTPacket(data: data, topic: topic, qos: qos))
        } catch {
            courierEventHandler.onEvent(.init(connectionInfo: client.connectOptions, event: .messageSendFailure(topic: topic, qos: qos, error: error, sizeBytes: 0)))
            throw error
        }
    }

    func subscribe(_ topics: (topic: String, qos: QoS)...) {
        subscribe(topics)
    }

    func subscribe(_ topics: [(topic: String, qos: QoS)]) {
        subscriptionStore.subscribe(topics)
        client.subscribe(topics)
    }

    func unsubscribe(_ topics: String...) {
        unsubscribe(topics)
    }

    func unsubscribe(_ topics: [String]) {
        let unsubTopics = topics.filter { !subscriptionStore.isCurrentlyPendingUnsubscribe(topic: $0) }
        guard !unsubTopics.isEmpty else { return }
        subscriptionStore.unsubscribe(unsubTopics)
        client.unsubscribe(unsubTopics)
    }

    func addEventHandler(_ handler: ICourierEventHandler) {
        if handler is CourierClient {
            printDebug("Adding Event Handler with CourierClient as type is not supported")
            return
        }
        courierEventHandler.addEventHandler(handler)
    }

    func removeEventHandler(_ handler: ICourierEventHandler) {
        courierEventHandler.removeEventHandler(handler)
    }

    func publishConnectionState(_ connectionState: ConnectionState) {
        dispatchQueue.async { [weak self] in
            self?.connectionSubject.onNext(connectionState)
        }
    }

    func destroy() {
        isDestroyed  = true
        subscriptionStore.clearAllSubscriptions()
        client.deleteAllPersistedMessages()
        client.messageReceiverListener.clearPersistedMessages()
        disconnect()
    }

    func disconnect() {
        clearConnectionTimerAndFlags()
        client.destroy()
    }

    func clearConnectionTimerAndFlags() {
        authFailureReconnectTimer?.stop()
        authenticationTimeoutTimer?.stop()
        isAuthenticating = false
    }

    deinit {
        client.destroy()
        connectionSubject.onCompleted()
    }

    private func printSubscribeDebug(topic: String) {
        #if DEBUG
        if subscriptionStore.subscriptions[topic] == nil {
            print("COURIER: You haven't subscribed to the topic: \(topic). Please subscribe to this topic first before you can receive new message")
        }
        #endif
    }
}

extension MQTTCourierClient: IAuthFailureHandler {
    func handleAuthFailure() {
        client.disconnect(isInternal: true)
        connectionServiceProvider.clearCachedAuthResponse()
        connect()
    }
}

extension MQTTCourierClient {
    
    func generateSinkInitiatedClosure(topic: String) -> (() -> ())? {
        guard config.incomingMessagePersistenceEnabled else { return nil }
        return { [weak self] in
            guard let self = self else { return}
            printDebug("COURIER - Sink Initiated, topic: \(topic)")
            self.client.messageReceiverListener.addPublisherDict(topic: topic)
        }
    }
    
    func generateSinkCancelledClosure(topic: String) -> (() -> ())? {
        guard config.incomingMessagePersistenceEnabled else { return nil }
        return { [weak self] in
            guard let self = self else { return}
            print("COURIER - Sink Cancelled, topic \(topic)")
            self.client.messageReceiverListener.removePublisherDict(topic: topic)
        }
    }
}

extension ConnectionState {

    var discardedReason: String? {
        switch self {
        case .connecting:
            return "Client connecting"
        case .connected:
            return "Client already connected"
        case .disconnected:
            return nil
        @unknown default:
            return nil
        }
    }

}

actor BoolActor {
    private var value: Bool
    init(_ initial: Bool) {
        self.value = initial
    }

    func get() -> Bool {
        return value
    }

    func set(_ newValue: Bool) {
        self.value = newValue
    }
}
