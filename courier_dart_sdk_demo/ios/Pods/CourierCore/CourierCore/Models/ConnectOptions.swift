import Foundation

public struct ConnectOptions: Equatable {

    public let host: String

    public let port: UInt16

    public let keepAlive: UInt16

    public let clientId: String

    public let username: String

    public let password: String

    public let isCleanSession: Bool
    
    public let userProperties: [String: String]?
    
    public let alpn: [String]?

    public init(
        host: String,
        port: UInt16,
        keepAlive: UInt16 = 60,
        clientId: String,
        username: String,
        password: String,
        isCleanSession: Bool = false,
        userProperties: [String: String]? = nil,
        alpn: [String]? = nil
    ) {
        self.host = host
        self.port = port
        self.keepAlive = keepAlive
        self.clientId = clientId
        self.username = username
        self.password = password
        self.isCleanSession = isCleanSession
        self.userProperties = userProperties
        self.alpn = alpn
    }
}
