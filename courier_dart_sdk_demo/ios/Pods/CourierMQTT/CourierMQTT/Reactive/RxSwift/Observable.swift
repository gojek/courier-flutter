class Observable<Element>: ObservableType {
    init() {
        #if TRACE_RESOURCES
        _ = Resources.incrementTotal()
        #endif
    }

    func subscribe<Observer: ObserverType>(_: Observer) -> Disposable where Observer.Element == Element {
        rxAbstractMethod()
    }

    func asObservable() -> Observable<Element> { self }

    deinit {
        #if TRACE_RESOURCES
        _ = Resources.decrementTotal()
        #endif
    }
}
