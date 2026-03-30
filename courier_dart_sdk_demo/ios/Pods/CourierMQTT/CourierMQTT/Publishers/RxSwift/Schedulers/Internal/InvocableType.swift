protocol InvocableType {
    func invoke()
}

protocol InvocableWithValueType {
    associatedtype Value

    func invoke(_ value: Value)
}
