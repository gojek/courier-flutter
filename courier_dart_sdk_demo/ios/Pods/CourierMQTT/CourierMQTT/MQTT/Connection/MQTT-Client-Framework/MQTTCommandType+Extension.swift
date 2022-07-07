import MQTTClientGJ

extension MQTTCommandType: CustomDebugStringConvertible {

    public var debugDescription: String {
        switch self {
        case ._None: return "None"
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
        case .pingreq: return "Ping"
        case .pingresp: return "Pong"
        case .disconnect: return "Disconnect"
        case .auth: return "Auth"
        default: return "Unknown"
        }
    }
}
