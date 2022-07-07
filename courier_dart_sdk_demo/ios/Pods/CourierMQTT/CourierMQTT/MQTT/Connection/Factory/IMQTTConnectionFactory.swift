import Foundation

protocol IMQTTConnectionFactory {

    func makeConnection(connectionConfig: ConnectionConfig) -> IMQTTConnection
}

struct MQTTClientFrameworkConnectionFactory: IMQTTConnectionFactory {

    let clientFactory: IMQTTClientFrameworkFactory

    func makeConnection(connectionConfig: ConnectionConfig) -> IMQTTConnection {
        MQTTClientFrameworkConnection(connectionConfig: connectionConfig, clientFactory: clientFactory)
    }

}
