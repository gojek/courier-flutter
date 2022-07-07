protocol SynchronizedUnsubscribeType: AnyObject {
    associatedtype DisposeKey

    func synchronizedUnsubscribe(_ disposeKey: DisposeKey)
}
