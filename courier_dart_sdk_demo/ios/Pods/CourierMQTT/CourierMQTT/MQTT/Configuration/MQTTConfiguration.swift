import CourierCore
import Foundation

struct MQTTConfiguration: IMQTTConfiguration {
    var connectRetryTimePolicy: IConnectRetryTimePolicy
    var connectTimeoutPolicy: IConnectTimeoutPolicy
    var idleActivityTimeoutPolicy: IdleActivityTimeoutPolicyProtocol
    var authFailureHandler: IAuthFailureHandler
    var eventHandler: ICourierEventHandler
    var messagePersistenceTTLSeconds: TimeInterval
    var messageCleanupInterval: TimeInterval
    var isMQTTPersistentEnabled: Bool
    var shouldInitializeCoreDataPersistenceContext: Bool

    init(connectRetryTimePolicy: IConnectRetryTimePolicy = ConnectRetryTimePolicy(),
         connectTimeoutPolicy: IConnectTimeoutPolicy = ConnectTimeoutPolicy(),
         idleActivityTimeoutPolicy: IdleActivityTimeoutPolicyProtocol = IdleActivityTimeoutPolicy(),
         authFailureHandler: IAuthFailureHandler,
         eventHandler: ICourierEventHandler,
         messagePersistenceTTLSeconds: TimeInterval = 0,
         messageCleanupInterval: TimeInterval = 10,
         isMQTTPersistentEnabled: Bool,
         shouldInitializeCoreDataPersistenceContext: Bool) {
        self.connectRetryTimePolicy = connectRetryTimePolicy
        self.connectTimeoutPolicy = connectTimeoutPolicy
        self.idleActivityTimeoutPolicy = idleActivityTimeoutPolicy
        self.authFailureHandler = authFailureHandler
        self.eventHandler = eventHandler
        self.messagePersistenceTTLSeconds = messagePersistenceTTLSeconds
        self.messageCleanupInterval = messageCleanupInterval
        self.isMQTTPersistentEnabled = isMQTTPersistentEnabled
        self.shouldInitializeCoreDataPersistenceContext = shouldInitializeCoreDataPersistenceContext
    }
}
