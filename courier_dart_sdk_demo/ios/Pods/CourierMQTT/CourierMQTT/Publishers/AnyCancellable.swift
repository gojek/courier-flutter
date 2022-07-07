import CourierCore
import Foundation

/// A type indicating that an activity or action supports cancellation.
final class DisposeCancellable: AnyCancellable {
    private var _disposable: Disposable?
    private var sinkCancelled: (() -> ())?

    init(_ disposable: Disposable, sinkCancelled: (() -> ())? = nil) {
        _disposable = disposable
        self.sinkCancelled = sinkCancelled
        super.init()
    }

    public override func cancel() {
        _disposable?.dispose()
        _disposable = nil
        sinkCancelled?()
    }

    deinit {
        cancel()
    }
}

