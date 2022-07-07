extension ObservableType {
    /**
     Returns an observable sequence that terminates with an `error`.

     - seealso: [throw operator on reactivex.io](http:

     - returns: The observable sequence that terminates with specified error.
     */
    static func error(_ error: Swift.Error) -> Observable<Element> {
        ErrorProducer(error: error)
    }
}

private final class ErrorProducer<Element>: Producer<Element> {
    private let error: Swift.Error

    init(error: Swift.Error) {
        self.error = error
    }

    override func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        observer.on(.error(error))
        return Disposables.create()
    }
}
