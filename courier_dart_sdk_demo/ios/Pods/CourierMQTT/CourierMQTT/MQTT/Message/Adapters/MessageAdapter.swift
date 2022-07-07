import Foundation

public protocol MessageAdapter {

    func fromMessage<T>(_ message: Data) throws -> T

    func toMessage<T>(data: T) throws -> Data
}
