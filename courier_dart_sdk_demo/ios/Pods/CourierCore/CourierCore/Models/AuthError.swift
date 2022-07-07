import Foundation

public enum AuthError: Error {

    case httpError(statusCode: Int)

    case otherError(NSError)

    public func asNSError() -> NSError {
        switch self {
        case .httpError:
            return CourierError.httpError.asNSError
        case .otherError(let error):
            return error
        }
    }
}
