protocol ObservableConvertibleType {

    associatedtype Element

    func asObservable() -> Observable<Element>
}
