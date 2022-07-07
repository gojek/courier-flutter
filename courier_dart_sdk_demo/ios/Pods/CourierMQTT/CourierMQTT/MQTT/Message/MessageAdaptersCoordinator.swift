import CourierCore
import Foundation

struct MessageAdaptersCoordinator {

    let messageAdapters: [MessageAdapter]

    func decodeMessage<D>(_ data: Data) -> D? {
        for adapter in messageAdapters {
            do {
                let decoded: D = try adapter.fromMessage(data)
                return decoded
            } catch {
                printDebug(error.localizedDescription)
            }
        }
        return nil
    }

    func encodeMessage<E>(_ data: E) throws -> Data {
        for adapter in messageAdapters {
            if let encoded = try? adapter.toMessage(data: data) {
                return encoded
            }
        }
        throw CourierError.encodingError
    }
}
