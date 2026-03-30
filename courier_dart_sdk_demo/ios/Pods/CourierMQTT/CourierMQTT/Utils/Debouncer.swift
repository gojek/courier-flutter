import Foundation

/// Marked `Debouncer` as `@unchecked Sendable` because it uses `Timer`, which is not `Sendable`,
/// and it maintains mutable state (`handler`, `timer`) that is assumed to be accessed from the main thread only.
/// Concurrency safety is ensured by restricting use to a single-threaded (typically main-thread) context.
final class Debouncer: @unchecked Sendable {
    
    private let timeInterval: TimeInterval
    private var timer: Timer?

    var handler: (() -> Void)?
    
    init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }
    
    func renewInterval() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false, block: { [weak self] (timer) in
            self?.timeIntervalDidFinish(for: timer)
        })
    }
    
    @objc private func timeIntervalDidFinish(for timer: Timer) {
        guard timer.isValid else {
            return
        }
        
        handler?()
        handler = nil
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
        handler = nil
    }
    
}

