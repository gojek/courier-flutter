import CourierCore
import Foundation

protocol IMQTTConnection {
    var isConnected: Bool { get }
    var isConnecting: Bool { get }
    var isDisconnected: Bool { get }
    var serverUri: String? { get }
    var hasExistingSession: Bool { get }

    func connect(connectOptions: ConnectOptions, messageReceiveListener: IMessageReceiveListener)
    func disconnect()

    func publish(packet: MQTTPacket)
    func deleteAllPersistedMessages()

    func subscribe(_ topics: [(topic: String, qos: QoS)])
    func unsubscribe(_ topics: [String])

    func setKeepAliveFailureHandler(handler: KeepAliveFailureHandler)
    func resetParams()
}
