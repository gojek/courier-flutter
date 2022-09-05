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

    case connectionServiceAuthStart(source: String? = nil)
    case connectionServiceAuthSuccess(host: String, port: Int)
    case connectionServiceAuthFailure(error: Error?)
    case connectedPacketSent
    case courierDisconnect(clearState: Bool)

    case connectionAttempt
    case connectionSuccess
    case connectionFailure(error: Error?)
    case connectionLost(error: Error?, diffLastInbound: Int?, diffLastOutbound: Int?)
    case connectionDisconnect
    case reconnect
    case connectDiscarded(reason: String)

    case subscribeAttempt(topic: String)
    case unsubscribeAttempt(topic: String)
    case subscribeSuccess(topic: String)
    case unsubscribeSuccess(topic: String)
    case subscribeFailure(topic: String, error: Error?)
    case unsubscribeFailure(topic: String, error: Error?)

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
