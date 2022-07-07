import CourierCore
import Foundation

protocol ISubscriptionStoreFactory {
    func makeStore(topics: [String: QoS]) -> ISubscriptionStore
}

struct SubscriptionStoreFactory: ISubscriptionStoreFactory {
    func makeStore(topics: [String: QoS]) -> ISubscriptionStore {
        return DiskSubscriptionStore(topics: topics)
    }
}
