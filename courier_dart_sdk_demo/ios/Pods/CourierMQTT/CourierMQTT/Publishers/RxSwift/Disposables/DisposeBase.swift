class DisposeBase {
    init() {
        #if TRACE_RESOURCES
        _ = Resources.incrementTotal()
        #endif
    }

    deinit {
        #if TRACE_RESOURCES
        _ = Resources.decrementTotal()
        #endif
    }
}
