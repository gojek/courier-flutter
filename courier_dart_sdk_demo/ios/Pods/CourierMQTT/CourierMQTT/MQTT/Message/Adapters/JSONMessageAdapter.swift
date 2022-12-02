import CourierCore
import Foundation

public struct JSONMessageAdapter: MessageAdapter {

    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder
    
    public var contentType: String { "application/json" }

    public init(jsonDecoder: JSONDecoder = JSONDecoder(),
                jsonEncoder: JSONEncoder = JSONEncoder()) {
        self.jsonDecoder = jsonDecoder
        self.jsonEncoder = jsonEncoder
    }

    public func fromMessage<T>(_ message: Data, topic: String) throws -> T {
        if let decodableType = T.self as? Decodable.Type,
           let value = try decodableType.init(data: message, jsonDecoder: jsonDecoder) as? T {
            return value
        }
        throw CourierError.decodingError.asNSError
    }

    public func toMessage<T>(data: T, topic: String) throws -> Data {
        guard !(data is Data) else {
            throw CourierError.encodingError.asNSError
        }

        if let encodable = data as? Encodable {
            return try encodable.encode(jsonEncoder: jsonEncoder)
        }
        throw CourierError.encodingError.asNSError
    }
}

fileprivate extension Decodable {

    init(data: Data, jsonDecoder: JSONDecoder) throws {
        self = try jsonDecoder.decode(Self.self, from: data)
    }
}

fileprivate extension Encodable {

    func encode(jsonEncoder: JSONEncoder) throws -> Data {
        try jsonEncoder.encode(self)
    }

}
