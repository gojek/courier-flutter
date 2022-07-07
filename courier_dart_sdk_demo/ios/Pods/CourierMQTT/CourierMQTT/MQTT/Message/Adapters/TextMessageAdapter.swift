import CourierCore
import Foundation

public struct TextMessageAdapter: MessageAdapter {

    public init() {}

    public func fromMessage<T>(_ message: Data) throws -> T {
        if let stringType = T.self as? String.Type,
           let value = stringType.init(data: message, encoding: .utf8) as? T {
            return value
        }
        throw CourierError.decodingError.asNSError
    }

    public func toMessage<T>(data: T) throws -> Data {
        if let string = data as? String,
           let data = string.data(using: .utf8) {
            return data
        }
        throw CourierError.encodingError.asNSError
    }

}
