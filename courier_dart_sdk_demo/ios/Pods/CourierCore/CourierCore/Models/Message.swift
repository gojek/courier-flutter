import Foundation

public struct Message {

    public let data: Data
    public let topic: String
    public let qos: QoS

    public init(data: Data, topic: String, qos: QoS) {
        self.data = data
        self.topic = topic
        self.qos = qos
    }
}
