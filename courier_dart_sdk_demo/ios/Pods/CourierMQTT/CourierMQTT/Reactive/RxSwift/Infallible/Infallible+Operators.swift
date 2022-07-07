extension InfallibleType {
    /**
     Returns an infallible sequence that contains a single element.

     - seealso: [just operator on reactivex.io](http:

     - parameter element: Single element in the resulting infallible sequence.

     - returns: An infallible sequence containing the single specified element.
     */
    static func just(_ element: Element) -> Infallible<Element> {
        Infallible(.just(element))
    }

    /**
     Returns an infallible sequence that contains a single element.

     - seealso: [just operator on reactivex.io](http:

     - parameter element: Single element in the resulting infallible sequence.
     - parameter scheduler: Scheduler to send the single element on.
     - returns: An infallible sequence containing the single specified element.
     */
    static func just(_ element: Element, scheduler: ImmediateSchedulerType) -> Infallible<Element> {
        Infallible(.just(element, scheduler: scheduler))
    }

    /**
     Returns an empty infallible sequence, using the specified scheduler to send out the single `Completed` message.

     - seealso: [empty operator on reactivex.io](http:

     - returns: An infallible sequence with no elements.
     */
    static func empty() -> Infallible<Element> {
        Infallible(.empty())
    }
}

extension InfallibleType {
    /**
     Filters the elements of an observable sequence based on a predicate.

     - seealso: [filter operator on reactivex.io](http:

     - parameter predicate: A function to test each source element for a condition.
     - returns: An observable sequence that contains elements from the input sequence that satisfy the condition.
     */
    func filter(_ predicate: @escaping (Element) -> Bool)
    -> Infallible<Element> {
        Infallible(asObservable().filter(predicate))
    }
}

extension InfallibleType {
    /**
     Projects each element of an observable sequence into a new form.

     - seealso: [map operator on reactivex.io](http:

     - parameter transform: A transform function to apply to each source element.
     - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.

     */
    func map<Result>(_ transform: @escaping (Element) -> Result)
    -> Infallible<Result> {
        Infallible(asObservable().map(transform))
    }

    /**
     Projects each element of an observable sequence into an optional form and filters all optional results.

     - parameter transform: A transform function to apply to each source element and which returns an element or nil.
     - returns: An observable sequence whose elements are the result of filtering the transform function for each element of the source.

     */
    func compactMap<Result>(_ transform: @escaping (Element) -> Result?)
    -> Infallible<Result> {
        Infallible(asObservable().compactMap(transform))
    }
}

extension InfallibleType {
    /**
     Projects each element of an observable sequence to an observable sequence and merges the resulting observable sequences into one observable sequence.

     - seealso: [flatMap operator on reactivex.io](http:

     - parameter selector: A transform function to apply to each element.
     - returns: An observable sequence whose elements are the result of invoking the one-to-many transform function on each element of the input sequence.
     */
    func flatMap<Source: ObservableConvertibleType>(_ selector: @escaping (Element) -> Source)
    -> Infallible<Source.Element> {
        Infallible(asObservable().flatMap(selector))
    }

    /**
     Projects each element of an observable sequence into a new sequence of observable sequences and then
     transforms an observable sequence of observable sequences into an observable sequence producing values only from the most recent observable sequence.

     It is a combination of `map` + `switchLatest` operator

     - seealso: [flatMapLatest operator on reactivex.io](http:

     - parameter selector: A transform function to apply to each element.
     - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source producing an
     Observable of Observable sequences and that at any point in time produces the elements of the most recent inner observable sequence that has been received.
     */
    func flatMapLatest<Source: ObservableConvertibleType>(_ selector: @escaping (Element) -> Source)
    -> Infallible<Source.Element> {
        Infallible(asObservable().flatMapLatest(selector))
    }

    /**
     Projects each element of an observable sequence to an observable sequence and merges the resulting observable sequences into one observable sequence.
     If element is received while there is some projected observable sequence being merged it will simply be ignored.

     - seealso: [flatMapFirst operator on reactivex.io](http:

     - parameter selector: A transform function to apply to element that was observed while no observable is executing in parallel.
     - returns: An observable sequence whose elements are the result of invoking the one-to-many transform function on each element of the input sequence that was received while no other sequence was being calculated.
     */
    func flatMapFirst<Source: ObservableConvertibleType>(_ selector: @escaping (Element) -> Source)
    -> Infallible<Source.Element> {
        Infallible(asObservable().flatMapFirst(selector))
    }
}

extension Infallible {
    /**
     Invokes an action for each event in the infallible sequence, and propagates all observer messages through the result sequence.

     - seealso: [do operator on reactivex.io](http:

     - parameter onNext: Action to invoke for each element in the observable sequence.
     - parameter afterNext: Action to invoke for each element after the observable has passed an onNext event along to its downstream.
     - parameter onCompleted: Action to invoke upon graceful termination of the observable sequence.
     - parameter afterCompleted: Action to invoke after graceful termination of the observable sequence.
     - parameter onSubscribe: Action to invoke before subscribing to source observable sequence.
     - parameter onSubscribed: Action to invoke after subscribing to source observable sequence.
     - parameter onDispose: Action to invoke after subscription to source observable has been disposed for any reason. It can be either because sequence terminates for some reason or observer subscription being disposed.
     - returns: The source sequence with the side-effecting behavior applied.
     */
    func `do`(onNext: ((Element) throws -> Void)? = nil, afterNext: ((Element) throws -> Void)? = nil, onCompleted: (() throws -> Void)? = nil, afterCompleted: (() throws -> Void)? = nil, onSubscribe: (() -> Void)? = nil, onSubscribed: (() -> Void)? = nil, onDispose: (() -> Void)? = nil) -> Infallible<Element> {
        Infallible(asObservable().do(onNext: onNext, afterNext: afterNext, onCompleted: onCompleted, afterCompleted: afterCompleted, onSubscribe: onSubscribe, onSubscribed: onSubscribed, onDispose: onDispose))
    }
}
