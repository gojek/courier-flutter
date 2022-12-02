import Foundation

public struct CourierEvent {
    public let connectionInfo: ConnectOptions?
    public let type: CourierEventType
    
    public init(connectionInfo: ConnectOptions?, event: CourierEventType) {
        self.connectionInfo = connectionInfo
        self.type = event
    }
}

public enum CourierEventType {

    case connectionServiceAuthStart
    case connectionServiceAuthSuccess(timeTaken: Int)
    case connectionServiceAuthFailure(timeTaken: Int, error: Error?)
    case connectedPacketSent
    case courierDisconnect(clearState: Bool)

    case connectionAttempt
    case connectionSuccess(timeTaken: Int)
    case connectionFailure(timeTaken: Int, error: Error?)
    case connectionLost(timeTaken: Int, error: Error?, diffLastInbound: Int?, diffLastOutbound: Int?)
    case connectionDisconnect
    case reconnect
    case connectDiscarded(reason: String)

    case subscribeAttempt(topics: [String])
    case unsubscribeAttempt(topics: [String])
    case subscribeSuccess(topics: [(topic: String, qos: QoS)], timeTaken: Int)
    case unsubscribeSuccess(topics: [String], timeTaken: Int)
    case subscribeFailure(topics: [(topic: String, qos: QoS)], timeTaken: Int, error: Error?)
    case unsubscribeFailure(topics: [String], timeTaken: Int, error: Error?)

    case ping(url: String)
    case pongReceived(timeTaken: Int)
    case pingFailure(timeTaken: Int, error: Error?)

    case messageReceive(topic: String, sizeBytes: Int)
    case messageReceiveFailure(topic: String, error: Error?, sizeBytes: Int)

    case messageSend(topic: String, qos: QoS, sizeBytes: Int)
    case messageSendSuccess(topic: String, qos: QoS, sizeBytes: Int)
    case messageSendFailure(topic: String, qos: QoS, error: Error?, sizeBytes: Int)

    case appForeground
    case appBackground
    case connectionAvailable
    case connectionUnavailable

}
