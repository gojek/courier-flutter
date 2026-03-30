final class CompositeDisposable: DisposeBase, Cancelable {

    struct DisposeKey {
        fileprivate let key: BagKey
        fileprivate init(key: BagKey) {
            self.key = key
        }
    }

    private var lock = SpinLock()

    private var disposables: Bag<Disposable>? = Bag()

    var isDisposed: Bool {
        self.lock.performLocked { self.disposables == nil }
    }

    override init() {}

    init(_ disposable1: Disposable, _ disposable2: Disposable) {

        _ = disposables!.insert(disposable1)
        _ = disposables!.insert(disposable2)
    }

    init(_ disposable1: Disposable, _ disposable2: Disposable, _ disposable3: Disposable) {

        _ = disposables!.insert(disposable1)
        _ = disposables!.insert(disposable2)
        _ = disposables!.insert(disposable3)
    }

    init(_ disposable1: Disposable, _ disposable2: Disposable, _ disposable3: Disposable, _ disposable4: Disposable, _ disposables: Disposable...) {

        _ = self.disposables!.insert(disposable1)
        _ = self.disposables!.insert(disposable2)
        _ = self.disposables!.insert(disposable3)
        _ = self.disposables!.insert(disposable4)

        for disposable in disposables {
            _ = self.disposables!.insert(disposable)
        }
    }

    init(disposables: [Disposable]) {
        for disposable in disposables {
            _ = self.disposables!.insert(disposable)
        }
    }

    /**
     Adds a disposable to the CompositeDisposable or disposes the disposable if the CompositeDisposable is disposed.

     - parameter disposable: Disposable to add.
     - returns: Key that can be used to remove disposable from composite disposable. In case dispose bag was already
     disposed `nil` will be returned.
     */
    func insert(_ disposable: Disposable) -> DisposeKey? {
        let key = _insert(disposable)

        if key == nil {
            disposable.dispose()
        }

        return key
    }

    private func _insert(_ disposable: Disposable) -> DisposeKey? {
        lock.performLocked {
            let bagKey = self.disposables?.insert(disposable)
            return bagKey.map(DisposeKey.init)
        }
    }

    var count: Int {
        lock.performLocked { self.disposables?.count ?? 0 }
    }

    func remove(for disposeKey: DisposeKey) {
        _remove(for: disposeKey)?.dispose()
    }

    private func _remove(for disposeKey: DisposeKey) -> Disposable? {
        lock.performLocked { self.disposables?.removeKey(disposeKey.key) }
    }

    func dispose() {
        if let disposables = _dispose() {
            disposeAll(in: disposables)
        }
    }

    private func _dispose() -> Bag<Disposable>? {
        lock.performLocked {
            let current = self.disposables
            self.disposables = nil
            return current
        }
    }
}

extension Disposables {

    static func create(_ disposable1: Disposable, _ disposable2: Disposable, _ disposable3: Disposable) -> Cancelable {
        CompositeDisposable(disposable1, disposable2, disposable3)
    }

    static func create(_ disposable1: Disposable, _ disposable2: Disposable, _ disposable3: Disposable, _ disposables: Disposable ...) -> Cancelable {
        var disposables = disposables
        disposables.append(disposable1)
        disposables.append(disposable2)
        disposables.append(disposable3)
        return CompositeDisposable(disposables: disposables)
    }

    static func create(_ disposables: [Disposable]) -> Cancelable {
        switch disposables.count {
        case 2:
            return Disposables.create(disposables[0], disposables[1])
        default:
            return CompositeDisposable(disposables: disposables)
        }
    }
}
