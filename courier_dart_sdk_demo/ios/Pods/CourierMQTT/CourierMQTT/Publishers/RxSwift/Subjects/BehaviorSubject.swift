final class BehaviorSubject<Element>: Observable<Element>,
                                      SubjectType,
                                      ObserverType,
                                      SynchronizedUnsubscribeType,
                                      Cancelable {
    typealias SubjectObserverType = BehaviorSubject<Element>

    typealias Observers = AnyObserver<Element>.s
    typealias DisposeKey = Observers.KeyType

    var hasObservers: Bool {
        lock.performLocked { self.observers.count > 0 }
    }

    let lock = RecursiveLock()

    private var disposed = false
    private var element: Element
    private var observers = Observers()
    private var stoppedEvent: Event<Element>?

    #if DEBUG
    private let synchronizationTracker = SynchronizationTracker()
    #endif

    var isDisposed: Bool {
        disposed
    }

    init(value: Element) {
        element = value

        #if TRACE_RESOURCES
        _ = Resources.incrementTotal()
        #endif
    }

    func value() throws -> Element {
        lock.lock()
        defer { self.lock.unlock() }
        if isDisposed {
            throw RxError.disposed(object: self)
        }

        if let error = stoppedEvent?.error {

            throw error
        } else {
            return element
        }
    }

    func on(_ event: Event<Element>) {
        #if DEBUG
        synchronizationTracker.register(synchronizationErrorMessage: .default)
        defer { self.synchronizationTracker.unregister() }
        #endif
        dispatch(synchronized_on(event), event)
    }

    func synchronized_on(_ event: Event<Element>) -> Observers {
        lock.lock()
        defer { self.lock.unlock() }
        if stoppedEvent != nil || isDisposed {
            return Observers()
        }

        switch event {
        case let .next(element):
            self.element = element
        case .error, .completed:
            stoppedEvent = event
        }

        return observers
    }

    override func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        lock.performLocked { self.synchronized_subscribe(observer) }
    }

    func synchronized_subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        if isDisposed {
            observer.on(.error(RxError.disposed(object: self)))
            return Disposables.create()
        }

        if let stoppedEvent = self.stoppedEvent {
            observer.on(stoppedEvent)
            return Disposables.create()
        }

        let key = observers.insert(observer.on)
        observer.on(.next(element))

        return SubscriptionDisposable(owner: self, key: key)
    }

    func synchronizedUnsubscribe(_ disposeKey: DisposeKey) {
        lock.performLocked { self.synchronized_unsubscribe(disposeKey) }
    }

    func synchronized_unsubscribe(_ disposeKey: DisposeKey) {
        if isDisposed {
            return
        }

        _ = observers.removeKey(disposeKey)
    }

    func asObserver() -> BehaviorSubject<Element> {
        self
    }

    func dispose() {
        lock.performLocked {
            self.disposed = true
            self.observers.removeAll()
            self.stoppedEvent = nil
        }
    }

    #if TRACE_RESOURCES
    deinit {
        _ = Resources.decrementTotal()
    }
    #endif
}
