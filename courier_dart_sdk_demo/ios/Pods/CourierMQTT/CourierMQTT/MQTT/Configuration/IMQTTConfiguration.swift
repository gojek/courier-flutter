import CourierCore
import Foundation

protocol IMQTTConfiguration {
    var connectRetryTimePolicy: IConnectRetryTimePolicy { get }
    var connectTimeoutPolicy: IConnectTimeoutPolicy { get }
    var idleActivityTimeoutPolicy: IdleActivityTimeoutPolicyProtocol { get }
    var authFailureHandler: IAuthFailureHandler { get }
    var eventHandler: ICourierEventHandler { get }
    
    var messagePersistenceTTLSeconds: TimeInterval { get }
    var messageCleanupInterval: TimeInterval { get }
    
    var isMQTTPersistentEnabled: Bool { get }
}
