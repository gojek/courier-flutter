import Foundation

struct ConnectRetryTimePolicy: IConnectRetryTimePolicy {
    public var enableAutoReconnect: Bool
    public var autoReconnectInterval: UInt16
    public var maxAutoReconnectInterval: UInt16

    init(enableAutoReconnect: Bool = true,
         autoReconnectInterval: UInt16 = 5,
         maxAutoReconnectInterval: UInt16 = 10) {
        self.enableAutoReconnect = enableAutoReconnect
        self.autoReconnectInterval = autoReconnectInterval
        self.maxAutoReconnectInterval = maxAutoReconnectInterval
    }
}
