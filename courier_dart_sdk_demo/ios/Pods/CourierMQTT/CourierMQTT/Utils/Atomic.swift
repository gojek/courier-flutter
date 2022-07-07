import Foundation

final class Atomic<T> {
    private let dispatchQueue = DispatchQueue(label: "courier.courier.atomic", attributes: .concurrent)
    private var _value: T
    init(_ value: T) {
        self._value = value
    }

    var value: T { dispatchQueue.sync { _value } }

    func mutate(execute task: (inout T) -> Void) {
        dispatchQueue.sync(flags: .barrier) { task(&_value) }
    }

    func mapValue<U>(handler: ((T) -> U)) -> U {
        dispatchQueue.sync { handler(_value) }
    }

}
