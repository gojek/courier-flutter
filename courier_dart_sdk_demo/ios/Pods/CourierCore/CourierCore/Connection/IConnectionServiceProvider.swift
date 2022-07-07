import Foundation

public protocol IConnectionServiceProvider: AnyObject {

    var clientId: String { get }

    var existingConnectOptions: ConnectOptions? { get }

    var extraIdProvider: (() -> String?)? { get set }

    func getConnectOptions(completion: @escaping (Result<ConnectOptions, AuthError>) -> Void)

    func clearCachedAuthResponse()
}

public extension IConnectionServiceProvider {

    var existingConnectOptions: ConnectOptions? { nil }

    func clearCachedAuthResponse() {}

}
