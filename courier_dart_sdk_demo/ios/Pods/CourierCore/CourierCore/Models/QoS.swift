import Foundation

public enum QoS: Int, Sendable {
    
    // http://docs.oasis-open.org/mqtt/mqtt/v3.1.1/os/mqtt-v3.1.1-os.html#_Toc398718100
    case zero = 0
    
    // http://docs.oasis-open.org/mqtt/mqtt/v3.1.1/os/mqtt-v3.1.1-os.html#_Toc398718100
    case one = 1
    
    // http://docs.oasis-open.org/mqtt/mqtt/v3.1.1/os/mqtt-v3.1.1-os.html#_Toc398718100
    case two = 2
    
    /** Like QoS1, Message delivery is acknowledged with Puback, but unlike Qos1 messages are
       nor persisted and neither retied at send after one attempt.
       The message arrives at the receiver either once or not at all.
        Your broker need to be configured to support this **/
    case oneWithoutPersistenceAndNoRetry = 3
    
    /** Like QoS1, Message delivery is acknowledged with Puback, but unlike Qos1 messages are
       nor persisted and neither retied at send after one attempt.
       The message arrives at the receiver either once or not at all.
        Your broker need to be configured to support this **/
    case oneWithoutPersistenceAndRetry = 4
    
    public var rawValue: Int {
        switch self {
        case .zero:
            return 0
        case .one, .oneWithoutPersistenceAndNoRetry, .oneWithoutPersistenceAndRetry:
            return 1
        case .two:
            return 2
        }
    }
    
    public var type: Int {
        switch self {
        case .zero:
            return 0
        case .one:
            return 1
        case .two:
            return 2
        case .oneWithoutPersistenceAndNoRetry:
            return 3
        case .oneWithoutPersistenceAndRetry:
            return 4
        }
    }
}
