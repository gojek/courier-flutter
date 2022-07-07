import Foundation

enum MQTTError: Int, Error, LocalizedError {
    case clientException = 0x00
    case invalidProtocolVersion = 0x01
    case invalidClientID = 0x02
    case brokerUnavailable = 0x03
    case failedAuthentication = 0x04
    case notAuthorized = 0x05
    case unexpectedError = 0x06
    case clientTimeout = 32000
    case noMessageIdsAvailable = 32001
    case clientConnected = 32100
    case clientAlreadyDisconnected = 32101
    case clientDisconnecting = 32102
    case serverConnectError = 32103
    case clientNotConnected = 32104
    case socketFactoryMismatch = 32105
    case sslConfigError = 32106
    case clientDisconnectProhibited = 32107
    case invalidMessage = 32108
    case connectionLost = 32109
    case connectInProgress = 32110
    case reasonCodeClientClosed = 32111
    case reasonCodeTokenInUse = 32201

    static let serialVersionUID = 300

    var errorDescription: String? {
        return "\(localizedDescription): \(rawValue)"
    }
}
