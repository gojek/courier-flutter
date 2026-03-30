struct AnyObserver<Element>: ObserverType {

    typealias EventHandler = (Event<Element>) -> Void

    private let observer: EventHandler

    init(eventHandler: @escaping EventHandler) {
        observer = eventHandler
    }

    init<Observer: ObserverType>(_ observer: Observer) where Observer.Element == Element {
        self.observer = observer.on
    }

    func on(_ event: Event<Element>) {
        observer(event)
    }

    func asObserver() -> AnyObserver<Element> {
        self
    }
}

extension AnyObserver {

    typealias s = Bag<(Event<Element>) -> Void>
}

extension ObserverType {

    func asObserver() -> AnyObserver<Element> {
        AnyObserver(self)
    }

    func mapObserver<Result>(_ transform: @escaping (Result) throws -> Element) -> AnyObserver<Result> {
        AnyObserver { e in
            self.on(e.map(transform))
        }
    }
}
