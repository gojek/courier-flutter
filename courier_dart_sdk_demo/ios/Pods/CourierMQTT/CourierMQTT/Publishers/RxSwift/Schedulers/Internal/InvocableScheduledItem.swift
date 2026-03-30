struct InvocableScheduledItem<I: InvocableWithValueType>: InvocableType {
    let invocable: I
    let state: I.Value

    init(invocable: I, state: I.Value) {
        self.invocable = invocable
        self.state = state
    }

    func invoke() {
        invocable.invoke(state)
    }
}
