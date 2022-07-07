/**
 In case nobody holds this lock, the work will be queued and executed immediately
 on thread that is requesting lock.

 In case there is somebody currently holding that lock, action will be enqueued.
 When owned of the lock finishes with it's processing, it will also execute
 and pending work.

 That means that enqueued work could possibly be executed later on a different thread.
 */
final class AsyncLock<I: InvocableType>: Disposable,
                                         Lock,
                                         SynchronizedDisposeType {
    typealias Action = () -> Void

    private var _lock = SpinLock()

    private var queue: Queue<I> = Queue(capacity: 0)

    private var isExecuting: Bool = false
    private var hasFaulted: Bool = false

    func lock() {
        _lock.lock()
    }

    func unlock() {
        _lock.unlock()
    }

    private func enqueue(_ action: I) -> I? {
        lock()
        defer { self.unlock() }
        if hasFaulted {
            return nil
        }

        if isExecuting {
            queue.enqueue(action)
            return nil
        }

        isExecuting = true

        return action
    }

    private func dequeue() -> I? {
        lock()
        defer { self.unlock() }
        if !queue.isEmpty {
            return queue.dequeue()
        } else {
            isExecuting = false
            return nil
        }
    }

    func invoke(_ action: I) {
        let firstEnqueuedAction = enqueue(action)

        if let firstEnqueuedAction = firstEnqueuedAction {
            firstEnqueuedAction.invoke()
        } else {

            return
        }

        while true {
            let nextAction = dequeue()

            if let nextAction = nextAction {
                nextAction.invoke()
            } else {
                return
            }
        }
    }

    func dispose() {
        synchronizedDispose()
    }

    func synchronized_dispose() {
        queue = Queue(capacity: 0)
        hasFaulted = true
    }
}
