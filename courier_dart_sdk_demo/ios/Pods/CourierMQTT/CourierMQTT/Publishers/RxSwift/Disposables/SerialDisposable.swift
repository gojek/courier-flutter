final class SerialDisposable: DisposeBase, Cancelable {
    private var lock = SpinLock()

    private var current = nil as Disposable?
    private var disposed = false

    var isDisposed: Bool {
        self.disposed
    }

    override init() {
        super.init()
    }

    /**
     Gets or sets the underlying disposable.

     Assigning this property disposes the previous disposable object.

     If the `SerialDisposable` has already been disposed, assignment to this property causes immediate disposal of the given disposable object.
     */
    var disposable: Disposable {
        get {
            lock.performLocked {
                self.current ?? Disposables.create()
            }
        }
        set(newDisposable) {
            let disposable: Disposable? = lock.performLocked {
                if self.isDisposed {
                    return newDisposable
                } else {
                    let toDispose = self.current
                    self.current = newDisposable
                    return toDispose
                }
            }

            if let disposable = disposable {
                disposable.dispose()
            }
        }
    }

    func dispose() {
        _dispose()?.dispose()
    }

    private func _dispose() -> Disposable? {
        lock.performLocked {
            guard !self.isDisposed else { return nil }

            self.disposed = true
            let current = self.current
            self.current = nil
            return current
        }
    }
}
