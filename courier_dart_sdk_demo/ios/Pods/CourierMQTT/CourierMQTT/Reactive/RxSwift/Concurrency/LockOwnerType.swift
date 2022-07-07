protocol LockOwnerType: AnyObject, Lock {
    var lock: RecursiveLock { get }
}

extension LockOwnerType {
    func lock() { lock.lock() }
    func unlock() { lock.unlock() }
}
