import Foundation
import MQTTClientGJ

protocol IMQTTPersistenceFactory {
    func makePersistence() -> MQTTPersistence
}

struct MQTTPersistenceFactory: IMQTTPersistenceFactory {

    func makePersistence() -> MQTTPersistence {
        MQTTCoreDataPersistence()
    }
}
