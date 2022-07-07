import CourierCore
import Foundation

extension ConnectionState {

    init(client: IMQTTClient) {
        if client.isConnected {
            self = .connected
        } else if client.isConnecting {
            self = .connecting
        } else {
            self = .disconnected
        }
    }

}
