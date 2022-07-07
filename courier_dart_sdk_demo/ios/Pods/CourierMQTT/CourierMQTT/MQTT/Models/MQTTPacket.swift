import CourierCore
import Foundation

struct MQTTPacket {
    let id: String
    var data: Data
    var topic: String
    var qos: QoS
    var timestamp: Date
    
    init(id: String = UUID().uuidString, data: Data, topic: String, qos: QoS, timestamp: Date = Date()) {
        self.id = id
        self.data = data
        self.topic = topic
        self.qos = qos
        self.timestamp = timestamp
    }
}

