import Foundation
import Reachability

protocol IMQTTClientFactory {
    func makeClient(configuration: IMQTTConfiguration, reachability: Reachability?, dispatchQueue: DispatchQueue) -> IMQTTClient
}

struct MQTTClientFactory: IMQTTClientFactory {

    func makeClient(configuration: IMQTTConfiguration, reachability: Reachability?, dispatchQueue: DispatchQueue) -> IMQTTClient {
        let factory = MQTTClientFrameworkConnectionFactory(clientFactory: MQTTClientFrameworkFactory())
        return MQTTClient(configuration: configuration, mqttConnectionFactory: factory, reachability: reachability, dispatchQueue: dispatchQueue)
    }
}
