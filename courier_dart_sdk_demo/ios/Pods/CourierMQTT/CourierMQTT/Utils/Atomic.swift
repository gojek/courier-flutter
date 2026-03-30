import Foundation

/// Marked `Atomic` as `@unchecked Sendable` because although it internally uses `DispatchQueue`,
/// which is not `Sendable`, all access to the wrapped value is synchronized using a concurrent queue
/// with barrier flags, ensuring thread safety. The `Box` container is also only accessed within these
/// controlled critical sections, making the wrapper safe for concurrent use despite the underlying non-Sendable components.

@propertyWrapper
final class Atomic<T>: @unchecked Sendable {
    private let dispatchQueue: DispatchQueue
    private var _box: Box<T>

    init(_ value: T, dispatchQueueLabel: String = "courier.courier.atomic") {
        self.dispatchQueue = DispatchQueue(label: dispatchQueueLabel, attributes: .concurrent)
        self._box = Box(value)
    }

    var wrappedValue: T {
        get {
            dispatchQueue.sync {
                _box.value
            }
        }
        set {
            dispatchQueue.sync(flags: .barrier) {
                self._box.value = newValue
            }
        }
    }

    func mutate(execute task: (inout T) -> Void) {
        dispatchQueue.sync(flags: .barrier) {
            task(&_box.value)
        }
    }

    func mapValue<U>(handler: (T) -> U) -> U {
        dispatchQueue.sync {
            handler(_box.value)
        }
    }
}

/// Marked `Box` as `@unchecked Sendable` because `T` may not be `Sendable`, and `Box` itself is a
/// simple container used only within synchronized contexts (like `Atomic`). All access to its
/// `value` is properly guarded by thread-safe mechanisms, ensuring safe concurrent usage.
private final class Box<T>: @unchecked Sendable {
    var value: T
    init(_ value: T) {
        self.value = value
    }
}
