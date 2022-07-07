import CourierCore
import Foundation

private let maxRetryCount = 3

class AuthRetryPolicy: IAuthRetryPolicy {
    let retryTime = 1
    private(set) var retryCount = 0

    init() {}

    func shouldRetry(error: Error) -> Bool {
        guard let authError = error as? AuthError else {
            return false
        }

        switch authError {
        case let .httpError(statusCode) where !(400 ... 499).contains(statusCode):
            return retryCount < maxRetryCount
        default:
            return false
        }
    }

    func getRetryTime() -> TimeInterval {
        retryCount += 1
        return Double(retryTime) * pow(2, Double(retryCount - 1))
    }

    func resetParams() {
        retryCount = 0
    }
}
