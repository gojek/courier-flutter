import Foundation

public protocol ICourierEventHandler: AnyObject {

    func reset()

    func onEvent(_ event: CourierEvent)
}

public extension ICourierEventHandler {
    func reset() {}
}
