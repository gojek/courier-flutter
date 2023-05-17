import Foundation
import MQTTClientGJ

protocol IMQTTPersistenceFactory {    
    func makePersistence() -> MQTTPersistence
}

struct MQTTPersistenceFactory: IMQTTPersistenceFactory {

    let isPersistent: Bool

    private let maxWindowSize: Int = 16
    private let maxMessages: Int = 5000
    private let maxSize: Int = 128 * 1024 * 1024
    
    init(isPersistent: Bool = false) {
        self.isPersistent = isPersistent
    }
    
    func makePersistence() -> MQTTPersistence {
        let persistence = MQTTCoreDataPersistence()
        persistence.persistent = isPersistent
        persistence.maxWindowSize = UInt(self.maxWindowSize)
        persistence.maxSize = UInt(self.maxSize)
        persistence.maxMessages = UInt(self.maxMessages)
        return persistence
    }
}
