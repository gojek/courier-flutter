struct SubscriptionDisposable<T: SynchronizedUnsubscribeType>: Disposable {
    private let key: T.DisposeKey
    private weak var owner: T?

    init(owner: T, key: T.DisposeKey) {
        self.owner = owner
        self.key = key
    }

    func dispose() {
        owner?.synchronizedUnsubscribe(key)
    }
}
