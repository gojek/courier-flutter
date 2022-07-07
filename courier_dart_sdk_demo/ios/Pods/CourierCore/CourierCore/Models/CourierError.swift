import Foundation

public enum CourierError: Int, Error, LocalizedError {

    public static let courierErrorDomain = "CourierErrorDomain"

    case sessionNotExist
    case httpError
    case decodingError
    case encodingError
    case connectOptionsNilError
    case messageSaveError
    case otherError

    public var errorDescription: String? {
        switch self {
        case .sessionNotExist:
            return "Courier Session does not exists. Please make sure to invoke Connect Attempt at least once. You can check the hasExistingSession property to verify the status or add Courier Event Handler and implement onMQTTConnectAttempt to get the callback when session has been made"
        case .httpError:
            return "HTTP Status Error"
        case .decodingError:
            return "Courier is unable to decode the message to data. Please provide a correct message adapter that can decode the message to Data format"
        case .encodingError:
            return "Courier is unable to encode the message to data. Please provide a correct message adapter that can encode the message to Data format"
        case .connectOptionsNilError:
            return "Connect options nil error"
        case .messageSaveError:
            return "Failed to save incoming message"
        case .otherError:
            return "An error occured"
        }
    }

    public var asNSError: NSError {
        NSError(domain: Self.courierErrorDomain, code: self.rawValue, userInfo: [NSLocalizedDescriptionKey: errorDescription ?? ""])
    }

}
