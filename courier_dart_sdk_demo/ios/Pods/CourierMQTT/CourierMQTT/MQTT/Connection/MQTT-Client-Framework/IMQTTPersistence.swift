import Foundation
import MQTTClientGJ

protocol IMQTTPersistenceFactory {    
    func makePersistence() -> MQTTPersistence
}

struct MQTTPersistenceFactory: IMQTTPersistenceFactory {

    let isDatabasePersistent: Bool
    let inMemoryPersistent: Bool

    private let maxWindowSize: Int = 16
    private let maxMessages: Int = 5000
    private let maxSize: Int = 128 * 1024 * 1024
    
    init(isDatabasePersistent: Bool = false, inMemoryPersistent: Bool = false) {
        self.isDatabasePersistent = isDatabasePersistent
        self.inMemoryPersistent = inMemoryPersistent
    }
    
    func makePersistence() -> MQTTPersistence {
        if inMemoryPersistent {
            let persistence = MQTTInMemoryPersistence()
            persistence.maxWindowSize = UInt(self.maxWindowSize)
            persistence.maxMessages = UInt(self.maxMessages)
            return persistence
        } else {
            let persistence = MQTTCoreDataPersistence()
            persistence.persistent = isDatabasePersistent
            persistence.maxWindowSize = UInt(self.maxWindowSize)
            persistence.maxSize = UInt(self.maxSize)
            persistence.maxMessages = UInt(self.maxMessages)
            return persistence
        }
    }
}
