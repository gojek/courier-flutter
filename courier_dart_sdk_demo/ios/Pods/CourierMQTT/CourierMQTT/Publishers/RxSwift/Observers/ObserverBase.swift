class ObserverBase<Element>: Disposable, ObserverType {
    private let isStopped = AtomicInt(0)

    func on(_ event: Event<Element>) {
        switch event {
        case .next:
            if load(isStopped) == 0 {
                onCore(event)
            }
        case .error, .completed:
            if fetchOr(isStopped, 1) == 0 {
                onCore(event)
            }
        }
    }

    func onCore(_: Event<Element>) {
        rxAbstractMethod()
    }

    func dispose() {
        fetchOr(isStopped, 1)
    }
}
