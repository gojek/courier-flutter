import Foundation

public protocol CourierClient: CourierSession {

    var hasExistingSession: Bool { get }

    func disconnect()

    func destroy()

}

public protocol CourierSession: CourierEventManager {

    var connectionState: ConnectionState { get }

    var connectionStatePublisher: AnyPublisher<ConnectionState, Never> { get }

    func connect()

    func connect(source: String)

    func subscribe(_ topics: (topic: String, qos: QoS)...)

    func subscribe(_ topics: [(topic: String, qos: QoS)])

    func unsubscribe(_ topics: String...)

    func unsubscribe(_ topics: [String])

    func publishMessage<E>(_ data: E, topic: String, qos: QoS) throws

    func messagePublisher<D>(topic: String) -> AnyPublisher<D, Never>

    func messagePublisher<D, E>(topic: String, errorDecodeHandler: @escaping ((E) -> Error)) -> AnyPublisher<Result<D, NSError>, Never>

    func messagePublisher() -> AnyPublisher<Message, Never>

}
