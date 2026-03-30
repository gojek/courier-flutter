extension ObservableType {
    /**
     Projects each element of an observable sequence to an observable sequence and merges the resulting observable sequences into one observable sequence.

     - seealso: [flatMap operator on reactivex.io](http:

     - parameter selector: A transform function to apply to each element.
     - returns: An observable sequence whose elements are the result of invoking the one-to-many transform function on each element of the input sequence.
     */
    func flatMap<Source: ObservableConvertibleType>(_ selector: @escaping (Element) throws -> Source)
    -> Observable<Source.Element> {
        return FlatMap(source: asObservable(), selector: selector)
    }
}

extension ObservableType {
    /**
     Projects each element of an observable sequence to an observable sequence and merges the resulting observable sequences into one observable sequence.
     If element is received while there is some projected observable sequence being merged it will simply be ignored.

     - seealso: [flatMapFirst operator on reactivex.io](http:

     - parameter selector: A transform function to apply to element that was observed while no observable is executing in parallel.
     - returns: An observable sequence whose elements are the result of invoking the one-to-many transform function on each element of the input sequence that was received while no other sequence was being calculated.
     */
    func flatMapFirst<Source: ObservableConvertibleType>(_ selector: @escaping (Element) throws -> Source)
    -> Observable<Source.Element> {
        return FlatMapFirst(source: asObservable(), selector: selector)
    }
}

extension ObservableType where Element: ObservableConvertibleType {
    /**
     Merges elements from all observable sequences in the given enumerable sequence into a single observable sequence.

     - seealso: [merge operator on reactivex.io](http:

     - returns: The observable sequence that merges the elements of the observable sequences.
     */
    func merge() -> Observable<Element.Element> {
        Merge(source: asObservable())
    }

    /**
     Merges elements from all inner observable sequences into a single observable sequence, limiting the number of concurrent subscriptions to inner sequences.

     - seealso: [merge operator on reactivex.io](http:

     - parameter maxConcurrent: Maximum number of inner observable sequences being subscribed to concurrently.
     - returns: The observable sequence that merges the elements of the inner sequences.
     */
    func merge(maxConcurrent: Int)
    -> Observable<Element.Element> {
        MergeLimited(source: asObservable(), maxConcurrent: maxConcurrent)
    }
}

extension ObservableType where Element: ObservableConvertibleType {
    /**
     Concatenates all inner observable sequences, as long as the previous observable sequence terminated successfully.

     - seealso: [concat operator on reactivex.io](http:

     - returns: An observable sequence that contains the elements of each observed inner sequence, in sequential order.
     */
    func concat() -> Observable<Element.Element> {
        merge(maxConcurrent: 1)
    }
}

extension ObservableType {
    /**
     Merges elements from all observable sequences from collection into a single observable sequence.

     - seealso: [merge operator on reactivex.io](http:

     - parameter sources: Collection of observable sequences to merge.
     - returns: The observable sequence that merges the elements of the observable sequences.
     */
    static func merge<Collection: Swift.Collection>(_ sources: Collection) -> Observable<Element> where Collection.Element == Observable<Element> {
        MergeArray(sources: Array(sources))
    }

    /**
     Merges elements from all observable sequences from array into a single observable sequence.

     - seealso: [merge operator on reactivex.io](http:

     - parameter sources: Array of observable sequences to merge.
     - returns: The observable sequence that merges the elements of the observable sequences.
     */
    static func merge(_ sources: [Observable<Element>]) -> Observable<Element> {
        MergeArray(sources: sources)
    }

    /**
     Merges elements from all observable sequences into a single observable sequence.

     - seealso: [merge operator on reactivex.io](http:

     - parameter sources: Collection of observable sequences to merge.
     - returns: The observable sequence that merges the elements of the observable sequences.
     */
    static func merge(_ sources: Observable<Element>...) -> Observable<Element> {
        MergeArray(sources: sources)
    }
}

extension ObservableType {
    /**
     Projects each element of an observable sequence to an observable sequence and concatenates the resulting observable sequences into one observable sequence.

     - seealso: [concat operator on reactivex.io](http:

     - returns: An observable sequence that contains the elements of each observed inner sequence, in sequential order.
     */

    func concatMap<Source: ObservableConvertibleType>(_ selector: @escaping (Element) throws -> Source)
    -> Observable<Source.Element> {
        return ConcatMap(source: asObservable(), selector: selector)
    }
}

private final class MergeLimitedSinkIter<SourceElement, SourceSequence: ObservableConvertibleType, Observer: ObserverType>: ObserverType,
                                                                                                                            LockOwnerType,
                                                                                                                            SynchronizedOnType where SourceSequence.Element == Observer.Element {
    typealias Element = Observer.Element
    typealias DisposeKey = CompositeDisposable.DisposeKey
    typealias Parent = MergeLimitedSink<SourceElement, SourceSequence, Observer>

    private let parent: Parent
    private let disposeKey: DisposeKey

    var lock: RecursiveLock {
        parent.lock
    }

    init(parent: Parent, disposeKey: DisposeKey) {
        self.parent = parent
        self.disposeKey = disposeKey
    }

    func on(_ event: Event<Element>) {
        synchronizedOn(event)
    }

    func synchronized_on(_ event: Event<Element>) {
        switch event {
        case .next:
            parent.forwardOn(event)
        case .error:
            parent.forwardOn(event)
            parent.dispose()
        case .completed:
            parent.group.remove(for: disposeKey)
            if let next = parent.queue.dequeue() {
                parent.subscribe(next, group: parent.group)
            } else {
                parent.activeCount -= 1

                if parent.stopped, parent.activeCount == 0 {
                    parent.forwardOn(.completed)
                    parent.dispose()
                }
            }
        }
    }
}

private final class ConcatMapSink<SourceElement, SourceSequence: ObservableConvertibleType, Observer: ObserverType>: MergeLimitedSink<SourceElement, SourceSequence, Observer> where Observer.Element == SourceSequence.Element {
    typealias Selector = (SourceElement) throws -> SourceSequence

    private let selector: Selector

    init(selector: @escaping Selector, observer: Observer, cancel: Cancelable) {
        self.selector = selector
        super.init(maxConcurrent: 1, observer: observer, cancel: cancel)
    }

    override func performMap(_ element: SourceElement) throws -> SourceSequence {
        try selector(element)
    }
}

private final class MergeLimitedBasicSink<SourceSequence: ObservableConvertibleType, Observer: ObserverType>: MergeLimitedSink<SourceSequence, SourceSequence, Observer> where Observer.Element == SourceSequence.Element {
    override func performMap(_ element: SourceSequence) throws -> SourceSequence {
        element
    }
}

private class MergeLimitedSink<SourceElement, SourceSequence: ObservableConvertibleType, Observer: ObserverType>: Sink<Observer>,
                                                                                                                  ObserverType where Observer.Element == SourceSequence.Element {
    typealias QueueType = Queue<SourceSequence>

    let maxConcurrent: Int

    let lock = RecursiveLock()

    var stopped = false
    var activeCount = 0
    var queue = QueueType(capacity: 2)

    let sourceSubscription = SingleAssignmentDisposable()
    let group = CompositeDisposable()

    init(maxConcurrent: Int, observer: Observer, cancel: Cancelable) {
        self.maxConcurrent = maxConcurrent
        super.init(observer: observer, cancel: cancel)
    }

    func run(_ source: Observable<SourceElement>) -> Disposable {
        _ = group.insert(sourceSubscription)

        let disposable = source.subscribe(self)
        sourceSubscription.setDisposable(disposable)
        return group
    }

    func subscribe(_ innerSource: SourceSequence, group: CompositeDisposable) {
        let subscription = SingleAssignmentDisposable()

        let key = group.insert(subscription)

        if let key = key {
            let observer = MergeLimitedSinkIter(parent: self, disposeKey: key)

            let disposable = innerSource.asObservable().subscribe(observer)
            subscription.setDisposable(disposable)
        }
    }

    func performMap(_: SourceElement) throws -> SourceSequence {
        rxAbstractMethod()
    }

    @inline(__always)
    private final func nextElementArrived(element: SourceElement) -> SourceSequence? {
        lock.performLocked {
            let subscribe: Bool
            if self.activeCount < self.maxConcurrent {
                self.activeCount += 1
                subscribe = true
            } else {
                do {
                    let value = try self.performMap(element)
                    self.queue.enqueue(value)
                } catch {
                    self.forwardOn(.error(error))
                    self.dispose()
                }
                subscribe = false
            }

            if subscribe {
                do {
                    return try self.performMap(element)
                } catch {
                    self.forwardOn(.error(error))
                    self.dispose()
                }
            }

            return nil
        }
    }

    func on(_ event: Event<SourceElement>) {
        switch event {
        case let .next(element):
            if let sequence = nextElementArrived(element: element) {
                subscribe(sequence, group: group)
            }
        case let .error(error):
            lock.performLocked {
                self.forwardOn(.error(error))
                self.dispose()
            }
        case .completed:
            lock.performLocked {
                if self.activeCount == 0 {
                    self.forwardOn(.completed)
                    self.dispose()
                } else {
                    self.sourceSubscription.dispose()
                }

                self.stopped = true
            }
        }
    }
}

private final class MergeLimited<SourceSequence: ObservableConvertibleType>: Producer<SourceSequence.Element> {
    private let source: Observable<SourceSequence>
    private let maxConcurrent: Int

    init(source: Observable<SourceSequence>, maxConcurrent: Int) {
        self.source = source
        self.maxConcurrent = maxConcurrent
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == SourceSequence.Element {
        let sink = MergeLimitedBasicSink<SourceSequence, Observer>(maxConcurrent: maxConcurrent, observer: observer, cancel: cancel)
        let subscription = sink.run(source)
        return (sink: sink, subscription: subscription)
    }
}

private final class MergeBasicSink<Source: ObservableConvertibleType, Observer: ObserverType>: MergeSink<Source, Source, Observer> where Observer.Element == Source.Element {
    override func performMap(_ element: Source) throws -> Source {
        element
    }
}

private final class FlatMapSink<SourceElement, SourceSequence: ObservableConvertibleType, Observer: ObserverType>: MergeSink<SourceElement, SourceSequence, Observer> where Observer.Element == SourceSequence.Element {
    typealias Selector = (SourceElement) throws -> SourceSequence

    private let selector: Selector

    init(selector: @escaping Selector, observer: Observer, cancel: Cancelable) {
        self.selector = selector
        super.init(observer: observer, cancel: cancel)
    }

    override func performMap(_ element: SourceElement) throws -> SourceSequence {
        try selector(element)
    }
}

private final class FlatMapFirstSink<SourceElement, SourceSequence: ObservableConvertibleType, Observer: ObserverType>: MergeSink<SourceElement, SourceSequence, Observer> where Observer.Element == SourceSequence.Element {
    typealias Selector = (SourceElement) throws -> SourceSequence

    private let selector: Selector

    override var subscribeNext: Bool {
        activeCount == 0
    }

    init(selector: @escaping Selector, observer: Observer, cancel: Cancelable) {
        self.selector = selector
        super.init(observer: observer, cancel: cancel)
    }

    override func performMap(_ element: SourceElement) throws -> SourceSequence {
        try selector(element)
    }
}

private final class MergeSinkIter<SourceElement, SourceSequence: ObservableConvertibleType, Observer: ObserverType>: ObserverType where Observer.Element == SourceSequence.Element {
    typealias Parent = MergeSink<SourceElement, SourceSequence, Observer>
    typealias DisposeKey = CompositeDisposable.DisposeKey
    typealias Element = Observer.Element

    private let parent: Parent
    private let disposeKey: DisposeKey

    init(parent: Parent, disposeKey: DisposeKey) {
        self.parent = parent
        self.disposeKey = disposeKey
    }

    func on(_ event: Event<Element>) {
        parent.lock.performLocked {
            switch event {
            case let .next(value):
                self.parent.forwardOn(.next(value))
            case let .error(error):
                self.parent.forwardOn(.error(error))
                self.parent.dispose()
            case .completed:
                self.parent.group.remove(for: self.disposeKey)
                self.parent.activeCount -= 1
                self.parent.checkCompleted()
            }
        }
    }
}

private class MergeSink<SourceElement, SourceSequence: ObservableConvertibleType, Observer: ObserverType>: Sink<Observer>,
                                                                                                           ObserverType where Observer.Element == SourceSequence.Element {
    typealias ResultType = Observer.Element
    typealias Element = SourceElement

    let lock = RecursiveLock()

    var subscribeNext: Bool {
        true
    }

    let group = CompositeDisposable()
    let sourceSubscription = SingleAssignmentDisposable()

    var activeCount = 0
    var stopped = false

    override init(observer: Observer, cancel: Cancelable) {
        super.init(observer: observer, cancel: cancel)
    }

    func performMap(_: SourceElement) throws -> SourceSequence {
        rxAbstractMethod()
    }

    @inline(__always)
    private final func nextElementArrived(element: SourceElement) -> SourceSequence? {
        lock.performLocked {
            if !self.subscribeNext {
                return nil
            }

            do {
                let value = try self.performMap(element)
                self.activeCount += 1
                return value
            } catch let e {
                self.forwardOn(.error(e))
                self.dispose()
                return nil
            }
        }
    }

    func on(_ event: Event<SourceElement>) {
        switch event {
        case let .next(element):
            if let value = nextElementArrived(element: element) {
                subscribeInner(value.asObservable())
            }
        case let .error(error):
            lock.performLocked {
                self.forwardOn(.error(error))
                self.dispose()
            }
        case .completed:
            lock.performLocked {
                self.stopped = true
                self.sourceSubscription.dispose()
                self.checkCompleted()
            }
        }
    }

    func subscribeInner(_ source: Observable<Observer.Element>) {
        let iterDisposable = SingleAssignmentDisposable()
        if let disposeKey = group.insert(iterDisposable) {
            let iter = MergeSinkIter(parent: self, disposeKey: disposeKey)
            let subscription = source.subscribe(iter)
            iterDisposable.setDisposable(subscription)
        }
    }

    func run(_ sources: [Observable<Observer.Element>]) -> Disposable {
        activeCount += sources.count

        for source in sources {
            subscribeInner(source)
        }

        stopped = true

        checkCompleted()

        return group
    }

    @inline(__always)
    func checkCompleted() {
        if stopped, activeCount == 0 {
            forwardOn(.completed)
            dispose()
        }
    }

    func run(_ source: Observable<SourceElement>) -> Disposable {
        _ = group.insert(sourceSubscription)

        let subscription = source.subscribe(self)
        sourceSubscription.setDisposable(subscription)

        return group
    }
}

private final class FlatMap<SourceElement, SourceSequence: ObservableConvertibleType>: Producer<SourceSequence.Element> {
    typealias Selector = (SourceElement) throws -> SourceSequence

    private let source: Observable<SourceElement>

    private let selector: Selector

    init(source: Observable<SourceElement>, selector: @escaping Selector) {
        self.source = source
        self.selector = selector
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == SourceSequence.Element {
        let sink = FlatMapSink(selector: selector, observer: observer, cancel: cancel)
        let subscription = sink.run(source)
        return (sink: sink, subscription: subscription)
    }
}

private final class FlatMapFirst<SourceElement, SourceSequence: ObservableConvertibleType>: Producer<SourceSequence.Element> {
    typealias Selector = (SourceElement) throws -> SourceSequence

    private let source: Observable<SourceElement>

    private let selector: Selector

    init(source: Observable<SourceElement>, selector: @escaping Selector) {
        self.source = source
        self.selector = selector
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == SourceSequence.Element {
        let sink = FlatMapFirstSink<SourceElement, SourceSequence, Observer>(selector: selector, observer: observer, cancel: cancel)
        let subscription = sink.run(source)
        return (sink: sink, subscription: subscription)
    }
}

final class ConcatMap<SourceElement, SourceSequence: ObservableConvertibleType>: Producer<SourceSequence.Element> {
    typealias Selector = (SourceElement) throws -> SourceSequence

    private let source: Observable<SourceElement>
    private let selector: Selector

    init(source: Observable<SourceElement>, selector: @escaping Selector) {
        self.source = source
        self.selector = selector
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == SourceSequence.Element {
        let sink = ConcatMapSink<SourceElement, SourceSequence, Observer>(selector: selector, observer: observer, cancel: cancel)
        let subscription = sink.run(source)
        return (sink: sink, subscription: subscription)
    }
}

final class Merge<SourceSequence: ObservableConvertibleType>: Producer<SourceSequence.Element> {
    private let source: Observable<SourceSequence>

    init(source: Observable<SourceSequence>) {
        self.source = source
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == SourceSequence.Element {
        let sink = MergeBasicSink<SourceSequence, Observer>(observer: observer, cancel: cancel)
        let subscription = sink.run(source)
        return (sink: sink, subscription: subscription)
    }
}

private final class MergeArray<Element>: Producer<Element> {
    private let sources: [Observable<Element>]

    init(sources: [Observable<Element>]) {
        self.sources = sources
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let sink = MergeBasicSink<Observable<Element>, Observer>(observer: observer, cancel: cancel)
        let subscription = sink.run(sources)
        return (sink: sink, subscription: subscription)
    }
}
