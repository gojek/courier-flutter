import Foundation

public protocol IConnectTimeoutPolicy {
    var isEnabled: Bool { get }
    var timerInterval: TimeInterval { get }
    var timeout: TimeInterval { get }
}

public struct ConnectTimeoutPolicy: IConnectTimeoutPolicy {
    public var isEnabled: Bool
    public var timerInterval: TimeInterval
    public var timeout: TimeInterval

    public init(
        isEnabled: Bool = false,
        timerInterval: TimeInterval = 16,
        timeout: TimeInterval = 10
    ) {
        self.isEnabled = isEnabled
        self.timerInterval = timerInterval
        self.timeout = timeout
    }
}
