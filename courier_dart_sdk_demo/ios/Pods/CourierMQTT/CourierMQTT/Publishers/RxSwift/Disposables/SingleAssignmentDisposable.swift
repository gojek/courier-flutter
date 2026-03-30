/**
 Represents a disposable resource which only allows a single assignment of its underlying disposable resource.

 If an underlying disposable resource has already been set, future attempts to set the underlying disposable resource will throw an exception.
 */
final class SingleAssignmentDisposable: DisposeBase, Cancelable {
    private enum DisposeState: Int32 {
        case disposed = 1
        case disposableSet = 2
    }

    private let state = AtomicInt(0)
    private var disposable = nil as Disposable?

    var isDisposed: Bool {
        isFlagSet(self.state, DisposeState.disposed.rawValue)
    }

    override init() {
        super.init()
    }

    func setDisposable(_ disposable: Disposable) {
        self.disposable = disposable

        let previousState = fetchOr(state, DisposeState.disposableSet.rawValue)

        if (previousState & DisposeState.disposableSet.rawValue) != 0 {
            rxFatalError("oldState.disposable != nil")
        }

        if (previousState & DisposeState.disposed.rawValue) != 0 {
            disposable.dispose()
            self.disposable = nil
        }
    }

    func dispose() {
        let previousState = fetchOr(state, DisposeState.disposed.rawValue)

        if (previousState & DisposeState.disposed.rawValue) != 0 {
            return
        }

        if (previousState & DisposeState.disposableSet.rawValue) != 0 {
            guard let disposable = self.disposable else {
                rxFatalError("Disposable not set")
            }
            disposable.dispose()
            self.disposable = nil
        }
    }
}
