@frozen enum Event<Element> {

    case next(Element)

    case error(Swift.Error)

    case completed
}

extension Event: CustomDebugStringConvertible {

    var debugDescription: String {
        switch self {
        case let .next(value):
            return "next(\(value))"
        case let .error(error):
            return "error(\(error))"
        case .completed:
            return "completed"
        }
    }
}

extension Event {

    var isStopEvent: Bool {
        switch self {
        case .next: return false
        case .error, .completed: return true
        }
    }

    var element: Element? {
        if case let .next(value) = self {
            return value
        }
        return nil
    }

    var error: Swift.Error? {
        if case let .error(error) = self {
            return error
        }
        return nil
    }

    var isCompleted: Bool {
        if case .completed = self {
            return true
        }
        return false
    }
}

extension Event {

    func map<Result>(_ transform: (Element) throws -> Result) -> Event<Result> {
        do {
            switch self {
            case let .next(element):
                return .next(try transform(element))
            case let .error(error):
                return .error(error)
            case .completed:
                return .completed
            }
        } catch let e {
            return .error(e)
        }
    }
}

protocol EventConvertible {

    associatedtype Element

    var event: Event<Element> { get }
}

extension Event: EventConvertible {

    var event: Event<Element> { self }
}
