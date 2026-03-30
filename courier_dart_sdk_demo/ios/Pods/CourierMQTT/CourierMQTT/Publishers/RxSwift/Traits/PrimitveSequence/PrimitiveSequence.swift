struct PrimitiveSequence<Trait, Element> {
    let source: Observable<Element>

    init(raw: Observable<Element>) {
        source = raw
    }
}

protocol PrimitiveSequenceType {

    associatedtype Trait

    associatedtype Element

    var primitiveSequence: PrimitiveSequence<Trait, Element> { get }
}

extension PrimitiveSequence: PrimitiveSequenceType {

    var primitiveSequence: PrimitiveSequence<Trait, Element> {
        self
    }
}

extension PrimitiveSequence: ObservableConvertibleType {

    func asObservable() -> Observable<Element> {
        source
    }
}

extension PrimitiveSequence {
    /**
     Wraps the source sequence in order to run its observer callbacks on the specified scheduler.

     This only invokes observer callbacks on a `scheduler`. In case the subscription and/or unsubscription
     actions have side-effects that require to be run on a scheduler, use `subscribeOn`.

     - seealso: [observeOn operator on reactivex.io](http:

     - parameter scheduler: Scheduler to notify observers on.
     - returns: The source sequence whose observations happen on the specified scheduler.
     */
    func observe(on scheduler: ImmediateSchedulerType)
    -> PrimitiveSequence<Trait, Element> {
        PrimitiveSequence(raw: source.observe(on: scheduler))
    }

    /**
     Wraps the source sequence in order to run its observer callbacks on the specified scheduler.

     This only invokes observer callbacks on a `scheduler`. In case the subscription and/or unsubscription
     actions have side-effects that require to be run on a scheduler, use `subscribeOn`.

     - seealso: [observeOn operator on reactivex.io](http:

     - parameter scheduler: Scheduler to notify observers on.
     - returns: The source sequence whose observations happen on the specified scheduler.
     */
    @available(*, deprecated, renamed: "observe(on:)")
    func observeOn(_ scheduler: ImmediateSchedulerType)
    -> PrimitiveSequence<Trait, Element> {
        observe(on: scheduler)
    }

    /**
     Wraps the source sequence in order to run its subscription and unsubscription logic on the specified
     scheduler.

     This operation is not commonly used.

     This only performs the side-effects of subscription and unsubscription on the specified scheduler.

     In order to invoke observer callbacks on a `scheduler`, use `observeOn`.

     - seealso: [subscribeOn operator on reactivex.io](http:

     - parameter scheduler: Scheduler to perform subscription and unsubscription actions on.
     - returns: The source sequence whose subscriptions and unsubscriptions happen on the specified scheduler.
     */
    func subscribe(on scheduler: ImmediateSchedulerType)
    -> PrimitiveSequence<Trait, Element> {
        PrimitiveSequence(raw: source.subscribe(on: scheduler))
    }

    /**
     Wraps the source sequence in order to run its subscription and unsubscription logic on the specified
     scheduler.

     This operation is not commonly used.

     This only performs the side-effects of subscription and unsubscription on the specified scheduler.

     In order to invoke observer callbacks on a `scheduler`, use `observeOn`.

     - seealso: [subscribeOn operator on reactivex.io](http:

     - parameter scheduler: Scheduler to perform subscription and unsubscription actions on.
     - returns: The source sequence whose subscriptions and unsubscriptions happen on the specified scheduler.
     */
    @available(*, deprecated, renamed: "subscribe(on:)")
    func subscribeOn(_ scheduler: ImmediateSchedulerType)
    -> PrimitiveSequence<Trait, Element> {
        subscribe(on: scheduler)
    }

    /**
     Continues an observable sequence that is terminated by an error with the observable sequence produced by the handler.

     - seealso: [catch operator on reactivex.io](http:

     - parameter handler: Error handler function, producing another observable sequence.
     - returns: An observable sequence containing the source sequence's elements, followed by the elements produced by the handler's resulting observable sequence in case an error occurred.
     */
    func `catch`(_ handler: @escaping (Swift.Error) throws -> PrimitiveSequence<Trait, Element>)
    -> PrimitiveSequence<Trait, Element> {
        PrimitiveSequence(raw: source.catch { try handler($0).asObservable() })
    }
}
