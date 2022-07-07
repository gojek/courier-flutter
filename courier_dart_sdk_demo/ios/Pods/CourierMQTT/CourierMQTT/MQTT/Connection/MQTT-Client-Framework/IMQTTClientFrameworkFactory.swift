import Foundation
import MQTTClientGJ

protocol IMQTTClientFrameworkFactory {
    func makeSessionManager(
        connectRetryTimePolicy: IConnectRetryTimePolicy,
        persistenceFactory: IMQTTPersistenceFactory,
        dispatchQueue: DispatchQueue,
        delegate: MQTTClientFrameworkSessionManagerDelegate,
        connectTimeoutPolicy: IConnectTimeoutPolicy,
        idleActivityTimeoutPolicy: IdleActivityTimeoutPolicyProtocol
    ) -> IMQTTClientFrameworkSessionManager
}

struct MQTTClientFrameworkFactory: IMQTTClientFrameworkFactory {

    let isPersistenceEnabled: Bool

    func makeSessionManager(connectRetryTimePolicy: IConnectRetryTimePolicy, persistenceFactory: IMQTTPersistenceFactory, dispatchQueue: DispatchQueue, delegate: MQTTClientFrameworkSessionManagerDelegate, connectTimeoutPolicy: IConnectTimeoutPolicy,
                            idleActivityTimeoutPolicy: IdleActivityTimeoutPolicyProtocol) -> IMQTTClientFrameworkSessionManager {
        guard !MQTTClientcourier.isEmpty else { fatalError("Please use the MQTTClientGJ from courier podspecs") }

        let sessionManager = MQTTClientFrameworkSessionManager(
            persistence: isPersistenceEnabled,
            retryInterval: TimeInterval(connectRetryTimePolicy.autoReconnectInterval),
            maxRetryInterval: TimeInterval(connectRetryTimePolicy.maxAutoReconnectInterval),
            streamSSLLevel: kCFStreamSocketSecurityLevelNegotiatedSSL as String,
            queue: dispatchQueue,
            mqttPersistenceFactory: persistenceFactory,
            connectTimeoutPolicy: connectTimeoutPolicy,
            idleActivityTimeoutPolicy: idleActivityTimeoutPolicy
        )
        sessionManager.delegate = delegate

        #if INTEGRATION || DEBUG
        MQTTLog.setLogLevel(.info)
        #endif

        return sessionManager
    }
}
