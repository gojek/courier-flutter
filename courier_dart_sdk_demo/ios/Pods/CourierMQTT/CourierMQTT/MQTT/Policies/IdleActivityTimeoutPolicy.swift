import Foundation

public protocol IdleActivityTimeoutPolicyProtocol {
    var isEnabled: Bool { get }
    var timerInterval: TimeInterval { get }
    var inactivityTimeout: TimeInterval { get }
    var readTimeout: TimeInterval { get }
}

public struct IdleActivityTimeoutPolicy: IdleActivityTimeoutPolicyProtocol {
    public var isEnabled: Bool
    public var timerInterval: TimeInterval
    public var inactivityTimeout: TimeInterval
    public var readTimeout: TimeInterval

    public init(
        isEnabled: Bool = false,
        timerInterval: TimeInterval = 12,
        inactivityTimeout: TimeInterval = 10,
        readTimeout: TimeInterval = 40
    ) {
        self.isEnabled = isEnabled
        self.timerInterval = timerInterval
        self.inactivityTimeout = inactivityTimeout
        self.readTimeout = readTimeout
    }

}
