import Foundation

public protocol MessageAdapter {
    
    var contentType: String { get }

    func fromMessage<T>(_ message: Data, topic: String) throws -> T

    func toMessage<T>(data: T, topic: String) throws -> Data
}
