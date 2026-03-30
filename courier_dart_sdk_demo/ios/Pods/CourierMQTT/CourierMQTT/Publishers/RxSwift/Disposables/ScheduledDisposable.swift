nonisolated(unsafe) private let disposeScheduledDisposable: (ScheduledDisposable) -> Disposable = { sd in
    sd.disposeInner()
    return Disposables.create()
}

final class ScheduledDisposable: Cancelable {
    let scheduler: ImmediateSchedulerType

    private let disposed = AtomicInt(0)

    private var disposable: Disposable?

    var isDisposed: Bool {
        isFlagSet(disposed, 1)
    }

    /**
     Initializes a new instance of the `ScheduledDisposable` that uses a `scheduler` on which to dispose the `disposable`.

     - parameter scheduler: Scheduler where the disposable resource will be disposed on.
     - parameter disposable: Disposable resource to dispose on the given scheduler.
     */
    init(scheduler: ImmediateSchedulerType, disposable: Disposable) {
        self.scheduler = scheduler
        self.disposable = disposable
    }

    func dispose() {
        _ = scheduler.schedule(self, action: disposeScheduledDisposable)
    }

    func disposeInner() {
        if fetchOr(disposed, 1) == 0 {
            disposable!.dispose()
            disposable = nil
        }
    }
}
