import Dispatch
#if !os(Linux)
import Foundation
#endif

/**
 Abstracts work that needs to be performed on `DispatchQueue.main`. In case `schedule` methods are called from `DispatchQueue.main`, it will perform action immediately without scheduling.

 This scheduler is usually used to perform UI work.

 Main scheduler is a specialization of `SerialDispatchQueueScheduler`.

 This scheduler is optimized for `observeOn` operator. To ensure observable sequence is subscribed on main thread using `subscribeOn`
 operator please use `ConcurrentMainScheduler` because it is more optimized for that purpose.
 */
final class MainScheduler: SerialDispatchQueueScheduler {
    private let mainQueue: DispatchQueue

    let numberEnqueued = AtomicInt(0)

    init() {
        mainQueue = DispatchQueue.main
        super.init(serialQueue: mainQueue)
    }

    static let instance = MainScheduler()

    static let asyncInstance = SerialDispatchQueueScheduler(serialQueue: DispatchQueue.main)

    class func ensureExecutingOnScheduler(errorMessage: String? = nil) {
        if !DispatchQueue.isMain {
            rxFatalError(errorMessage ?? "Executing on background thread. Please use `MainScheduler.instance.schedule` to schedule work on main thread.")
        }
    }

    class func ensureRunningOnMainThread(errorMessage: String? = nil) {
        #if !os(Linux)
        guard Thread.isMainThread else {
            rxFatalError(errorMessage ?? "Running on background thread.")
        }
        #endif
    }

    override func scheduleInternal<StateType>(_ state: StateType, action: @escaping (StateType) -> Disposable) -> Disposable {
        let previousNumberEnqueued = increment(numberEnqueued)

        if DispatchQueue.isMain, previousNumberEnqueued == 0 {
            let disposable = action(state)
            decrement(numberEnqueued)
            return disposable
        }

        let cancel = SingleAssignmentDisposable()

        mainQueue.async {
            if !cancel.isDisposed {
                cancel.setDisposable(action(state))
            }

            decrement(self.numberEnqueued)
        }

        return cancel
    }
}
