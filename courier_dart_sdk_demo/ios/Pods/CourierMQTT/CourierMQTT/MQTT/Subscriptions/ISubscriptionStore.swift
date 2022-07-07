import CourierCore
import Foundation

protocol ISubscriptionStore {
    var subscriptions: [String: QoS] { get }
    var pendingUnsubscriptions: Set<String> { get }

    func subscribe(_ topics: [(topic: String, qos: QoS)])
    func unsubscribe(_ topics: [String])
    func unsubscribeAcked(_ topics: [String])

    func isCurrentlyPendingUnsubscribe(topic: String) -> Bool

    func clearAllSubscriptions()
}
