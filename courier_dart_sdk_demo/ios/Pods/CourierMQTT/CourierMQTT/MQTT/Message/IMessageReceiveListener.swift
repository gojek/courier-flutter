import CourierCore
import Foundation

protocol IMessageReceiveListener {
    func messageArrived(data: Data, topic: String, qos: QoS)
    func addPublisherDict(topic: String)
    func removePublisherDict(topic: String)
    func handlePersistedMessages()
    func clearPersistedMessages()
}
