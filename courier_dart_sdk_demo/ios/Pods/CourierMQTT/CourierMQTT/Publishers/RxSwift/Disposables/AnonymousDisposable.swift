private final class AnonymousDisposable: DisposeBase, Cancelable {
    typealias DisposeAction = () -> Void

    private let disposed = AtomicInt(0)
    private var disposeAction: DisposeAction?

    var isDisposed: Bool {
        isFlagSet(disposed, 1)
    }

    private init(_ disposeAction: @escaping DisposeAction) {
        self.disposeAction = disposeAction
        super.init()
    }

    fileprivate init(disposeAction: @escaping DisposeAction) {
        self.disposeAction = disposeAction
        super.init()
    }

    fileprivate func dispose() {
        if fetchOr(disposed, 1) == 0 {
            if let action = disposeAction {
                disposeAction = nil
                action()
            }
        }
    }
}

extension Disposables {

    static func create(with dispose: @escaping () -> Void) -> Cancelable {
        AnonymousDisposable(disposeAction: dispose)
    }
}
