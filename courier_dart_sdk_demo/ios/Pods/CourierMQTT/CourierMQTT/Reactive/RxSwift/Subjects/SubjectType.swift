protocol SubjectType: ObservableType {

    associatedtype Observer: ObserverType

    func asObserver() -> Observer
}
