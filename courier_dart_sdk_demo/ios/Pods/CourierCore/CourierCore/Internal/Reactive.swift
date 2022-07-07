import Foundation

open class AnyCancellable: Hashable {

    public init() {}

    open func cancel() {}

    public static func == (lhs: AnyCancellable, rhs: AnyCancellable) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    open func store<Cancellables: RangeReplaceableCollection>(
        in collection: inout Cancellables
    ) where Cancellables.Element == AnyCancellable {
        collection.append(self)
    }

    open func store(in set: inout Set<AnyCancellable>) {
        set.insert(self)
    }

}

open class AnyPublisher<Output, Failure: Error> {

    public init() {}

    open func filter(
        predicate: @escaping (Output) -> Bool
    ) -> AnyPublisher<Output, Failure> {
        assertionFailure("Implement in Subclass")
        return AnyPublisher<Output, Failure>()
    }

    open func map<Result>(
        transform: @escaping (Output) -> Result
    ) -> AnyPublisher<Result, Failure> {
        assertionFailure("Implement in Subclass")
        return AnyPublisher<Result, Failure>()
    }

    open func sink(
        receiveValue: @escaping (Output) -> Void
    ) -> AnyCancellable {
        assertionFailure("Implement in Subclass")
        return AnyCancellable()
    }
}
