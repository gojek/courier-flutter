import Foundation

protocol IAuthRetryPolicy {
    func shouldRetry(error: Error) -> Bool
    func getRetryTime() -> TimeInterval
    func resetParams()
}
