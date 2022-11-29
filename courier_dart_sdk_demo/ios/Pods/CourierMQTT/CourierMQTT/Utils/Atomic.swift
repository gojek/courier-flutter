import Foundation

@propertyWrapper
final class Atomic<T> {
    private let dispatchQueue: DispatchQueue
    private var _value: T

    init(_ value: T, dispatchQueueLabel: String = "courier.courier.atomic") {
        dispatchQueue = DispatchQueue(label: dispatchQueueLabel, attributes: .concurrent)
        self._value = value
    }
    
    var wrappedValue: T {
        get { dispatchQueue.sync { _value } }
        set {
            dispatchQueue.async(flags: .barrier) {
                self._value = newValue
            }
        }
    }
    
    func mutate(execute task: (inout T) -> Void) {
        dispatchQueue.sync(flags: .barrier) { task(&_value) }
    }
    
    
    func mapValue<U>(handler: ((T) -> U)) -> U {
        dispatchQueue.sync { handler(_value) }
    }

}
