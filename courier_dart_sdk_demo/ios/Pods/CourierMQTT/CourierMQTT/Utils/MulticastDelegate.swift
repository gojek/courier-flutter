import CourierCore
import Foundation

class MulticastDelegate<T> {

    private let atomic = Atomic<NSHashTable<AnyObject>>(NSHashTable.weakObjects())

    private var delegates: [AnyObject] {
        atomic.mapValue { $0.allObjects.reversed() }
    }

    func add(_ delegate: T) {
        atomic.mutate { $0.add(delegate as AnyObject) }
    }

    func remove(_ delegateToRemove: T) {
        atomic.mutate { $0.remove(delegateToRemove as AnyObject) }
    }

    func invoke(_ invocation: @escaping (T) -> Void) {
        var courierClient: CourierClient?

        let delegates = self.delegates
        for delegate in delegates {
            if let _courierClient = delegate as? CourierClient {
                courierClient = _courierClient
            } else if let _delegate = delegate as? T {
                invocation(_delegate)
            }
        }

        if let courierClient = courierClient as? T {
            invocation(courierClient)
        }
    }
}
