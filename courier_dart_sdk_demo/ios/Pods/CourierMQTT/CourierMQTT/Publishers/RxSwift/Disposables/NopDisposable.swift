private struct NopDisposable: Disposable {
    nonisolated(unsafe) fileprivate static let noOp: Disposable = NopDisposable()

    private init() {}

    func dispose() {}
}

extension Disposables {
    /**
     Creates a disposable that does nothing on disposal.
     */
    static func create() -> Disposable { NopDisposable.noOp }
}
