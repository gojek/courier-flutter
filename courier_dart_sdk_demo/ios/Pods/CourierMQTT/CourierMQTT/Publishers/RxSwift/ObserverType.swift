protocol ObserverType {

    associatedtype Element

    func on(_ event: Event<Element>)
}

extension ObserverType {

    func onNext(_ element: Element) {
        on(.next(element))
    }

    func onCompleted() {
        on(.completed)
    }

    func onError(_ error: Swift.Error) {
        on(.error(error))
    }
}
