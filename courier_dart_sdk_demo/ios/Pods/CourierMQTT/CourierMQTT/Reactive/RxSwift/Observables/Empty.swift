extension ObservableType {
    /**
     Returns an empty observable sequence, using the specified scheduler to send out the single `Completed` message.

     - seealso: [empty operator on reactivex.io](http:

     - returns: An observable sequence with no elements.
     */
    static func empty() -> Observable<Element> {
        EmptyProducer<Element>()
    }
}

private final class EmptyProducer<Element>: Producer<Element> {
    override func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        observer.on(.completed)
        return Disposables.create()
    }
}
