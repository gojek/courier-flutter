import Foundation

protocol IConnectRetryTimePolicy {
    var enableAutoReconnect: Bool { get }
    var autoReconnectInterval: UInt16 { get }
    var maxAutoReconnectInterval: UInt16 { get }
}
