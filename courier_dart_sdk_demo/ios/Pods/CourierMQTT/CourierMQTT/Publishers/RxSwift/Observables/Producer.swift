class Producer<Element>: Observable<Element> {
    override init() {
        super.init()
    }

    override func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        if !CurrentThreadScheduler.isScheduleRequired {

            let disposer = SinkDisposer()
            let sinkAndSubscription = run(observer, cancel: disposer)
            disposer.setSinkAndSubscription(sink: sinkAndSubscription.sink, subscription: sinkAndSubscription.subscription)

            return disposer
        } else {
            return CurrentThreadScheduler.instance.schedule(()) { _ in
                let disposer = SinkDisposer()
                let sinkAndSubscription = self.run(observer, cancel: disposer)
                disposer.setSinkAndSubscription(sink: sinkAndSubscription.sink, subscription: sinkAndSubscription.subscription)

                return disposer
            }
        }
    }

    func run<Observer: ObserverType>(_: Observer, cancel _: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        rxAbstractMethod()
    }
}

private final class SinkDisposer: Cancelable {
    private enum DisposeState: Int32 {
        case disposed = 1
        case sinkAndSubscriptionSet = 2
    }

    private let state = AtomicInt(0)
    private var sink: Disposable?
    private var subscription: Disposable?

    var isDisposed: Bool {
        isFlagSet(state, DisposeState.disposed.rawValue)
    }

    func setSinkAndSubscription(sink: Disposable, subscription: Disposable) {
        self.sink = sink
        self.subscription = subscription

        let previousState = fetchOr(state, DisposeState.sinkAndSubscriptionSet.rawValue)
        if (previousState & DisposeState.sinkAndSubscriptionSet.rawValue) != 0 {
            rxFatalError("Sink and subscription were already set")
        }

        if (previousState & DisposeState.disposed.rawValue) != 0 {
            sink.dispose()
            subscription.dispose()
            self.sink = nil
            self.subscription = nil
        }
    }

    func dispose() {
        let previousState = fetchOr(state, DisposeState.disposed.rawValue)

        if (previousState & DisposeState.disposed.rawValue) != 0 {
            return
        }

        if (previousState & DisposeState.sinkAndSubscriptionSet.rawValue) != 0 {
            guard let sink = self.sink else {
                rxFatalError("Sink not set")
            }
            guard let subscription = self.subscription else {
                rxFatalError("Subscription not set")
            }

            sink.dispose()
            subscription.dispose()

            self.sink = nil
            self.subscription = nil
        }
    }
}
