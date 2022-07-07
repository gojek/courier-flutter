import CourierCore
import Foundation

public struct DataMessageAdapter: MessageAdapter {

    public init() {}

    public func fromMessage<T>(_ message: Data) throws -> T {
        if let value = message as? T {
            return value
        }
        throw CourierError.decodingError.asNSError
    }

    public func toMessage<T>(data: T) throws -> Data {
        if let _data = data as? Data {
            return _data
        }
        throw CourierError.encodingError.asNSError
    }
}
