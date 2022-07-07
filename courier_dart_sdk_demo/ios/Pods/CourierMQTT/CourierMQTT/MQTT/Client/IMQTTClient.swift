import CourierCore
import Foundation

protocol IMQTTClient {
    var isConnected: Bool { get }
    var isConnecting: Bool { get }
    var hasExistingSession: Bool { get }

    var connectOptions: ConnectOptions? { get }
    var subscribedMessageStream: Observable<MQTTPacket> { get }
    var messageReceiverListener: IMessageReceiveListener { get }

    func connect(connectOptions: ConnectOptions)
    func reconnect()
    func disconnect()

    func subscribe(_ topics: [(topic: String, qos: QoS)])
    func unsubscribe(_ topics: [String])

    func send(packet: MQTTPacket)
    func deleteAllPersistedMessages(clientId: String)

    func reset()
    func destroy()
    func setKeepAliveFailureHandler(handler: KeepAliveFailureHandler)
}
