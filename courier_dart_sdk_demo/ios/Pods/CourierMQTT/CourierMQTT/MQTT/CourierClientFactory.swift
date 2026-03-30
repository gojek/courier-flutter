import CourierCore
import Foundation

public struct CourierClientFactory {

    public init() {}

    /**
     Creates an instance of CourierClient that uses MQTT as its bi-directional communication protocol
     - Parameter config: MQTTClientConfig

     - Returns: CourierClient
     */
    public func makeMQTTClient(config: MQTTClientConfig) -> CourierClient {
        MQTTCourierClient(config: config)
    }
}

public struct MQTTClientConfig {

    public let topics: [String: QoS]

    public let authService: IConnectionServiceProvider

    public let messageAdapters: [MessageAdapter]

    public let isMessagePersistenceEnabled: Bool

    public let isMessageInMemoryPersistenceEnabled: Bool

    public let autoReconnectInterval: UInt16

    public let maxAutoReconnectInterval: UInt16

    public let connectTimeoutPolicy: IConnectTimeoutPolicy

    public let idleActivityTimeoutPolicy: IdleActivityTimeoutPolicyProtocol

    public let enableAuthenticationTimeout: Bool

    public let authenticationTimeoutInterval: TimeInterval
        
    public let messagePersistenceTTLSeconds: TimeInterval
    
    public let messageCleanupInterval: TimeInterval
    
    public let shouldInitializeCoreDataPersistenceContext: Bool
    
    public var incomingMessagePersistenceEnabled: Bool {
        messagePersistenceTTLSeconds > 0
    }

    public init(
        topics: [String: QoS] = [:],
        authService: IConnectionServiceProvider,
        messageAdapters: [MessageAdapter] = [JSONMessageAdapter()],
        isMessagePersistenceEnabled: Bool = false,
        isMessageInMemoryPersistenceEnabled: Bool = false,
        autoReconnectInterval: UInt16 = 5,
        maxAutoReconnectInterval: UInt16 = 10,
        enableAuthenticationTimeout: Bool = false,
        authenticationTimeoutInterval: TimeInterval = 30,
        connectTimeoutPolicy: IConnectTimeoutPolicy = ConnectTimeoutPolicy(),
        idleActivityTimeoutPolicy: IdleActivityTimeoutPolicyProtocol = IdleActivityTimeoutPolicy(),
        messagePersistenceTTLSeconds: TimeInterval = 0,
        messageCleanupInterval: TimeInterval = 10,
        shouldInitializeCoreDataPersistenceContext: Bool = true
    ) {
        self.topics = topics
        self.authService = authService
        self.messageAdapters = messageAdapters
        self.isMessagePersistenceEnabled = isMessagePersistenceEnabled
        self.isMessageInMemoryPersistenceEnabled = isMessageInMemoryPersistenceEnabled
        self.autoReconnectInterval = autoReconnectInterval
        self.maxAutoReconnectInterval = maxAutoReconnectInterval
        self.enableAuthenticationTimeout = enableAuthenticationTimeout
        self.authenticationTimeoutInterval = authenticationTimeoutInterval
        self.connectTimeoutPolicy = connectTimeoutPolicy
        self.idleActivityTimeoutPolicy = idleActivityTimeoutPolicy
        self.messagePersistenceTTLSeconds = messagePersistenceTTLSeconds
        self.messageCleanupInterval = messageCleanupInterval
        self.shouldInitializeCoreDataPersistenceContext = shouldInitializeCoreDataPersistenceContext
    }

}
