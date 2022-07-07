import MQTTClientGJ

extension MQTTSessionEvent: CustomDebugStringConvertible {

    public var debugDescription: String {
        switch self {
        case .connected: return "Connected"
        case .connectionClosed: return "Connection Closed"
        case .connectionClosedByBroker: return "Connection Closed by Broker"
        case .connectionError: return "Connection Error"
        case .connectionRefused: return "Connection Refused"
        case .protocolError: return "Protocol Error"
        default: return "Unknown"
        }
    }

}
