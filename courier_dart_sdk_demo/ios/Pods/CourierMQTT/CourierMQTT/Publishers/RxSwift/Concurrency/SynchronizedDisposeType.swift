protocol SynchronizedDisposeType: AnyObject, Disposable, Lock {
    func synchronized_dispose()
}

extension SynchronizedDisposeType {
    func synchronizedDispose() {
        lock()
        defer { self.unlock() }
        synchronized_dispose()
    }
}
