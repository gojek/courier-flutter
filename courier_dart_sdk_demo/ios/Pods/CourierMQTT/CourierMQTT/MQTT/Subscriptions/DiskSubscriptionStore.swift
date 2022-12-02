import CourierCore
import UIKit

class DiskSubscriptionStore: ISubscriptionStore {

    private let pendingUnsubKey: String
    private let userDefaults: UserDefaults

    @Atomic<[String: QoS]>([:]) private(set) var subscriptions
    @Atomic<[String]>([]) private(set) var _pendingUnsubscriptions
    private(set) var pendingUnsubscriptions: Set<String> {
        get { Set(_pendingUnsubscriptions) }
        set {
            userDefaults.setValue(Array(newValue), forKey: pendingUnsubKey)
            _pendingUnsubscriptions = Array(newValue)
        }
    }

    init(topics: [String: QoS] = [:],
         pendingUnsubKey: String = "Courier.PendingUnsubs",
         userDefaults: UserDefaults = .standard
    ) {
        self.userDefaults = userDefaults
        self.pendingUnsubKey = pendingUnsubKey

        self.subscriptions = topics
        self._pendingUnsubscriptions = userDefaults.stringArray(forKey: pendingUnsubKey) ?? []
    }

    func subscribe(_ topics: [(topic: String, qos: QoS)]) {
        internalSubscribe(topics)
    }

    func unsubscribe(_ topics: [String]) {
        internalUnsubscribe(topics)
    }

    func unsubscribeAcked(_ topics: [String]) {
        topics.forEach { pendingUnsubscriptions.remove($0) }
    }

    func isCurrentlyPendingUnsubscribe(topic: String) -> Bool {
        pendingUnsubscriptions.contains(topic)
    }

    func clearAllSubscriptions() {
        subscriptions.removeAll()
        pendingUnsubscriptions.removeAll()
        userDefaults.removeObject(forKey: pendingUnsubKey)
    }

    private func internalSubscribe(_ topicFilters: [(String, QoS)]) {
        topicFilters.forEach { topicFilter in
            let (topic, qos) = topicFilter
            pendingUnsubscriptions.remove(topic)
            subscriptions[topic] = qos
        }
    }

    private func internalUnsubscribe(_ topics: [String]) {
        topics.forEach { topic in
            pendingUnsubscriptions.insert(topic)
            subscriptions[topic] = nil
        }
    }

}
