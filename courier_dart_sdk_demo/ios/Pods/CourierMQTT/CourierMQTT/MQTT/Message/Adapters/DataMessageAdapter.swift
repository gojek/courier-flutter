import CourierCore
import Foundation

public struct DataMessageAdapter: MessageAdapter {

    public var contentType: String { "application/octet-stream" }
    
    public init() {}

    public func fromMessage<T>(_ message: Data, topic: String) throws -> T {
        if let value = message as? T {
            return value
        }
        throw CourierError.decodingError.asNSError
    }

    public func toMessage<T>(data: T, topic: String) throws -> Data {
        if let _data = data as? Data {
            return _data
        }
        throw CourierError.encodingError.asNSError
    }
}
