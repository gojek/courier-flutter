import CourierCore
import Foundation

public struct TextMessageAdapter: MessageAdapter {

    public var contentType: String { "text/plain" }
    
    public init() {}

    public func fromMessage<T>(_ message: Data, topic: String) throws -> T {
        if let stringType = T.self as? String.Type,
           let value = stringType.init(data: message, encoding: .utf8) as? T {
            return value
        }
        throw CourierError.decodingError.asNSError
    }

    public func toMessage<T>(data: T, topic: String) throws -> Data {
        if let string = data as? String,
           let data = string.data(using: .utf8) {
            return data
        }
        throw CourierError.encodingError.asNSError
    }

}
