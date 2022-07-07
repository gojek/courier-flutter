import Foundation
import Reachability

protocol IMQTTClientFactory {
    func makeClient(configuration: IMQTTConfiguration, reachability: Reachability?, dispatchQueue: DispatchQueue) -> IMQTTClient
}

struct MQTTClientFactory: IMQTTClientFactory {

    let isPersistenceEnabled: Bool

    func makeClient(configuration: IMQTTConfiguration, reachability: Reachability?, dispatchQueue: DispatchQueue) -> IMQTTClient {
        let factory = MQTTClientFrameworkConnectionFactory(clientFactory: MQTTClientFrameworkFactory(isPersistenceEnabled: isPersistenceEnabled))
        return MQTTClient(configuration: configuration, mqttConnectionFactory: factory, reachability: reachability, dispatchQueue: dispatchQueue)
    }
}
