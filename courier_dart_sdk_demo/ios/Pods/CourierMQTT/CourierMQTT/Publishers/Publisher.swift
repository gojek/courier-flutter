import CourierCore
import Foundation


public final class PassthroughSubject<Output, Failure: Error>: AnyPublisher<Output, Failure> {
    
    private var observable: Observable<Output>
    private var sinkInitiated: (() -> ())?
    private var sinkCancelled: (() -> ())?
    
    init(observable: Observable<Output>, sinkInitiated: (() -> ())? = nil, sinkCancelled: (() -> ())? = nil) {
        self.observable = observable
        self.sinkInitiated = sinkInitiated
        self.sinkCancelled = sinkCancelled
        super.init()
    }

    /// Republishes all elements that match a provided closure.
    public override func filter(
        predicate: @escaping (Output) -> Bool
    ) -> AnyPublisher<Output, Failure> {
        let observable = self.observable
            .observe(on: MainScheduler.asyncInstance)
            .filter(predicate)
        return PassthroughSubject(observable: observable, sinkInitiated: sinkInitiated, sinkCancelled: sinkCancelled)
    }
    
    /// Transforms all elements from the upstream publisher with a provided closure.
    public override func map<Result>(
        transform: @escaping (Output) -> Result
    ) -> AnyPublisher<Result, Failure> {
        let observable = self.observable
            .observe(on: MainScheduler.asyncInstance)
            .map(transform)
        return PassthroughSubject<Result, Failure>(observable: observable, sinkInitiated: sinkInitiated, sinkCancelled: sinkCancelled)
    }

    /// Attaches a subscriber with closure-based behavior to a publisher that never fails.
    public override func sink(
        receiveValue: @escaping (Output) -> Void
    ) -> AnyCancellable {
        let disposable = observable
            .observe(on: MainScheduler.asyncInstance)
            .subscribe { event in
                guard let value = event.element else { return }
                receiveValue(value)
            }
        sinkInitiated?()
        return DisposeCancellable(disposable, sinkCancelled: sinkCancelled)
    }
    
}

/// A subject that wraps a single value and publishes a new element whenever the value changes.
public final class CurrentValueSubject<Output, Failure: Error> {
    
    private let behaviorSubject: BehaviorSubject<Output>
    private var sinkInitiated: (() -> ())?
    private var sinkCancelled: (() -> ())?
    
    public init(_ initialValue: Output, sinkInitiated: (() -> ())? = nil, sinkCancelled: (() -> ())? = nil) {
        self.behaviorSubject = BehaviorSubject(value: initialValue)
        self.value = initialValue
        self.sinkInitiated = sinkInitiated
        self.sinkCancelled = sinkCancelled
    }
        
    /// The value wrapped by this subject, published as a new element whenever it changes.
    public var value: Output {
        didSet {
            let _value = value
            behaviorSubject.onNext(_value)
        }
    }
    
    /// Sends a value to the subscriber.
    public func send(_ value: Output) {
        self.value = value
    }
    
    /// Republishes all elements that match a provided closure.
    public func filter(
        predicate: @escaping (Output) -> Bool
    ) -> AnyPublisher<Output, Failure> {
        let observable = behaviorSubject
            .observe(on: MainScheduler.asyncInstance)
            .filter(predicate)
        return PassthroughSubject(observable: observable, sinkInitiated: sinkInitiated, sinkCancelled: sinkCancelled)
    }
    
    /// Transforms all elements from the upstream publisher with a provided closure.
    public func map<Result>(
        transform: @escaping (Output) -> Result
    ) -> AnyPublisher<Result, Failure> {
        let observable = behaviorSubject
            .observe(on: MainScheduler.asyncInstance)
            .map(transform)
        return PassthroughSubject<Result, Failure>(observable: observable)
    }
    
    /// Attaches a subscriber with closure-based behavior to a publisher that never fails.
    public func sink(
        receiveValue: @escaping (Output) -> Void
    ) -> AnyCancellable {
        let disposable = behaviorSubject
            .observe(on: MainScheduler.asyncInstance)
            .subscribe { event in
                guard let value = event.element else { return }
                receiveValue(value)
            }
        sinkInitiated?()
        return DisposeCancellable(disposable, sinkCancelled: sinkCancelled)
    }
    
    /// Wraps this publisher with a type eraser.
    public func eraseToAnyPublisher() -> AnyPublisher<Output, Failure> {
         let observable = behaviorSubject
             .asObservable()
             .observe(on: MainScheduler.asyncInstance)
        return PassthroughSubject(observable: observable, sinkInitiated: sinkInitiated, sinkCancelled: sinkCancelled)
     }
    
    deinit {
        behaviorSubject.onCompleted()
    }
    
}

