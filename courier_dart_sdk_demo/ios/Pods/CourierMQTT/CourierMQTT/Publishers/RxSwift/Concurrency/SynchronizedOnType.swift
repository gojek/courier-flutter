protocol SynchronizedOnType: AnyObject, ObserverType, Lock {
    func synchronized_on(_ event: Event<Element>)
}

extension SynchronizedOnType {
    func synchronizedOn(_ event: Event<Element>) {
        lock()
        defer { self.unlock() }
        synchronized_on(event)
    }
}
