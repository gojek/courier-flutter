import CourierCore
import MQTTClientGJ

extension MQTTSessionEvent {

    var description: String {
        switch self {
        case .connected: return "Connected"
        case .connectionRefused: return "Connection Refused"
        case .connectionClosed: return "Connection Closed"
        case .connectionError: return "Connection Error"
        case .protocolError: return "Protocol Error"
        case .connectionClosedByBroker: return "Connection closed by broker"
        default: return String(rawValue)
        }
    }
}

extension MQTTCommandType {

    var description: String {
        switch self {
        case .connect: return "Connect"
        case .connack: return "Connack"
        case .publish: return "Publish"
        case .puback: return "Puback"
        case .pubrec: return "Pubrec"
        case .pubrel: return "Pubrel"
        case .pubcomp: return "Pubcomp"
        case .subscribe: return "Subscribe"
        case .suback: return "Suback"
        case .unsubscribe: return "Unsubscribe"
        case .unsuback: return "Unsuback"
        case .pingreq: return "Pingreq"
        case .pingresp: return "PingResp"
        case .auth: return "Auth"
        default: return String(rawValue)
        }
    }
}

extension MQTTQosLevel {
    init(qos: QoS) {
        self = MQTTQosLevel(rawValue: UInt8(qos.type)) ?? .atMostOnce
    }
}
