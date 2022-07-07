import CourierCore
import Foundation

public struct PlistMessageAdapter: MessageAdapter {
    private let plistDecoder: PropertyListDecoder
    private let plistEncoder: PropertyListEncoder

    public init(plistDecoder: PropertyListDecoder = PropertyListDecoder(),
                plistEncoder: PropertyListEncoder = PropertyListEncoder()) {
        self.plistDecoder = plistDecoder
        self.plistEncoder = plistEncoder
    }

    public func fromMessage<T>(_ message: Data) throws -> T {
        if let decodableType = T.self as? Decodable.Type,
           let value = try decodableType.init(data: message, plistDecoder: plistDecoder) as? T {
            return value
        }
        throw CourierError.decodingError.asNSError
    }

    public func toMessage<T>(data: T) throws -> Data {
        if let encodable = data as? Encodable {
            return try encodable.encode(plistEncoder: plistEncoder)
        }
        throw CourierError.encodingError.asNSError
    }

}

fileprivate extension Decodable {

    init(data: Data, plistDecoder: PropertyListDecoder) throws {
        self = try plistDecoder.decode(Self.self, from: data)
    }
}

fileprivate extension Encodable {

    func encode(plistEncoder: PropertyListEncoder) throws -> Data {
        try plistEncoder.encode(self)
    }
}
