let RxErrorDomain = "RxErrorDomain"
let RxCompositeFailures = "RxCompositeFailures"

enum RxError: Swift.Error,
              CustomDebugStringConvertible {

    case unknown

    case disposed(object: AnyObject)

    case overflow

    case argumentOutOfRange

    case noElements

    case moreThanOneElement

    case timeout
}

extension RxError {

    var debugDescription: String {
        switch self {
        case .unknown:
            return "Unknown error occurred."
        case let .disposed(object):
            return "Object `\(object)` was already disposed."
        case .overflow:
            return "Arithmetic overflow occurred."
        case .argumentOutOfRange:
            return "Argument out of range."
        case .noElements:
            return "Sequence doesn't contain any elements."
        case .moreThanOneElement:
            return "Sequence contains more than one element."
        case .timeout:
            return "Sequence timeout."
        }
    }
}
