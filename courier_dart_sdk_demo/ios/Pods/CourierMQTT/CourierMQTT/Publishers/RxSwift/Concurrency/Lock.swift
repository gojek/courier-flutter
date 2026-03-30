protocol Lock {
    func lock()
    func unlock()
}

typealias SpinLock = RecursiveLock

extension RecursiveLock: Lock {
    @inline(__always)
    final func performLocked<T>(_ action: () -> T) -> T {
        lock()
        defer { self.unlock() }
        return action()
    }
}
