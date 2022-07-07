import CourierCore
import Foundation

struct ConnectionConfig {
    var connectRetryTimePolicy: IConnectRetryTimePolicy
    var eventHandler: ICourierEventHandler
    var authFailureHandler: IAuthFailureHandler
    var connectTimeoutPolicy: IConnectTimeoutPolicy
    var idleActivityTimeoutPolicy: IdleActivityTimeoutPolicyProtocol
}
