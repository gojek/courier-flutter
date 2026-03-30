final class PublishSubject<Element>: Observable<Element>,
                                     SubjectType,
                                     Cancelable,
                                     ObserverType,
                                     SynchronizedUnsubscribeType {
    typealias SubjectObserverType = PublishSubject<Element>

    typealias Observers = AnyObserver<Element>.s
    typealias DisposeKey = Observers.KeyType

    var hasObservers: Bool {
        lock.performLocked { self.observers.count > 0 }
    }

    private let lock = RecursiveLock()

    private var disposed = false
    private var observers = Observers()
    private var stopped = false
    private var stoppedEvent = nil as Event<Element>?

    #if DEBUG
    private let synchronizationTracker = SynchronizationTracker()
    #endif

    var isDisposed: Bool {
        self.disposed
    }

    override init() {
        super.init()
        #if TRACE_RESOURCES
        _ = Resources.incrementTotal()
        #endif
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
        switch event {
        case .next:
            if isDisposed || stopped {
                return Observers()
            }

            return observers
        case .completed, .error:
            if stoppedEvent == nil {
                stoppedEvent = event
                stopped = true
                let observers = self.observers
                self.observers.removeAll()
                return observers
            }

            return Observers()
        }
    }

    /**
     Subscribes an observer to the subject.

     - parameter observer: Observer to subscribe to the subject.
     - returns: Disposable object that can be used to unsubscribe the observer from the subject.
     */
    override func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        lock.performLocked { self.synchronized_subscribe(observer) }
    }

    func synchronized_subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        if let stoppedEvent = self.stoppedEvent {
            observer.on(stoppedEvent)
            return Disposables.create()
        }

        if isDisposed {
            observer.on(.error(RxError.disposed(object: self)))
            return Disposables.create()
        }

        let key = observers.insert(observer.on)
        return SubscriptionDisposable(owner: self, key: key)
    }

    func synchronizedUnsubscribe(_ disposeKey: DisposeKey) {
        lock.performLocked { self.synchronized_unsubscribe(disposeKey) }
    }

    func synchronized_unsubscribe(_ disposeKey: DisposeKey) {
        _ = observers.removeKey(disposeKey)
    }

    func asObserver() -> PublishSubject<Element> {
        self
    }

    func dispose() {
        lock.performLocked { self.synchronized_dispose() }
    }

    final func synchronized_dispose() {
        disposed = true
        observers.removeAll()
        stoppedEvent = nil
    }

    #if TRACE_RESOURCES
    deinit {
        _ = Resources.decrementTotal()
    }
    #endif
}
