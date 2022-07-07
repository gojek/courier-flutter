import Foundation
import MQTTClientGJ

protocol IMQTTSession: AnyObject {
    var persistence: MQTTPersistence! { get set }
    var delegate: MQTTSessionDelegate! { get set }
    var streamSSLLevel: String! { get set }
    var clientId: String! { get set }
    var userName: String! { get set }
    var password: String! { get set }
    var keepAliveInterval: UInt16 { get set}
    var cleanSessionFlag: Bool { get set }
    var willFlag: Bool { get set }
    var willTopic: String! { get set }
    var willMsg: Data! { get set }
    var willQoS: MQTTQosLevel { get set }
    var willRetainFlag: Bool { get set }
    var protocolLevel: MQTTProtocolVersion { get set }
    var queue: DispatchQueue! { get set }
    var transport: MQTTTransportProtocol! { get set }
    var certificates: [Any]! { get set }
    var voip: Bool { get set }
    var userProperty: [String: String]! { get set}

    var shouldEnableActivityCheckTimeout: Bool { get set }
    var shouldEnableConnectCheckTimeout: Bool { get set }

    var activityCheckTimerInterval: TimeInterval { get set }
    var connectTimeoutCheckTimerInterval: TimeInterval { get set }

    var connectTimeout: TimeInterval { get set }
    var connectTimestamp: TimeInterval { get }

    var inactivityTimeout: TimeInterval { get set }
    var readTimeout: TimeInterval { get set }
    var fastReconnectTimestamp: TimeInterval { get }
    var lastInboundActivityTimestamp: TimeInterval { get }
    var lastOutboundActivityTimestamp: TimeInterval { get }

    func connect(connectHandler: MQTTConnectHandler!)
    func close(disconnectHandler: MQTTDisconnectHandler!)

    @discardableResult
    func subscribe(toTopics topics: [String: NSNumber]!, subscribeHandler: MQTTSubscribeHandler!) -> UInt16
    @discardableResult
    func unsubscribeTopics(_ topics: [String]!, unsubscribeHandler: MQTTUnsubscribeHandler!) -> UInt16
    @discardableResult
    func publishData(_ data: Data!, onTopic topic: String!, retain retainFlag: Bool, qos: MQTTQosLevel, publishHandler: MQTTPublishHandler!) -> UInt16
}

extension MQTTSession: IMQTTSession {}

protocol IMQTTSessionFactory {
    func makeSession() -> IMQTTSession
}

struct MQTTSessionFactory: IMQTTSessionFactory {
    func makeSession() -> IMQTTSession {
        MQTTSession()
    }
}
