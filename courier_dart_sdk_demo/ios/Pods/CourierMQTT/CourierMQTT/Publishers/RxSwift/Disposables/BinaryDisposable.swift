private final class BinaryDisposable: DisposeBase, Cancelable {
    private let disposed = AtomicInt(0)

    private var disposable1: Disposable?
    private var disposable2: Disposable?

    var isDisposed: Bool {
        isFlagSet(disposed, 1)
    }

    init(_ disposable1: Disposable, _ disposable2: Disposable) {
        self.disposable1 = disposable1
        self.disposable2 = disposable2
        super.init()
    }

    func dispose() {
        if fetchOr(disposed, 1) == 0 {
            disposable1?.dispose()
            disposable2?.dispose()
            disposable1 = nil
            disposable2 = nil
        }
    }
}

extension Disposables {

    static func create(_ disposable1: Disposable, _ disposable2: Disposable) -> Cancelable {
        BinaryDisposable(disposable1, disposable2)
    }
}
