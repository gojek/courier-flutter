//
//  AuthService.swift
//  Runner
//
//  Created by Deepanshu on 20/01/22.
//

import Foundation
import CourierCore
import UIKit
import OSLog

final class AuthService: IConnectionServiceProvider {
    var extraIdProvider: (() -> String?)? = nil
    var clientId: String {
        existingConnectOptions?.clientId ??
        UIDevice.current.identifierForVendor?.uuidString ??
        UUID().uuidString
    }

    var methodChannelGetConnectOptionsHandler: (() -> Void)?
    public private(set) var existingConnectOptions: ConnectOptions?
    public private(set) var getConnectOptionsCompletion: ((Result<ConnectOptions, AuthError>) -> Void)?

    func getConnectOptions(completion: @escaping (Result<ConnectOptions, AuthError>) -> Void) {
        if let existingConnectOptions = existingConnectOptions {
            completion(.success(existingConnectOptions))
        } else {
            self.getConnectOptionsCompletion = completion
            self.methodChannelGetConnectOptionsHandler?()
        }
    }

    func setConnectOptions(_ options: ConnectOptions) {
       self.existingConnectOptions = options
       if let existingConnectOptionsCompletion = self.getConnectOptionsCompletion {
            os_log("Auth failure handler connect options callback")
            existingConnectOptionsCompletion(.success(options))
            self.getConnectOptionsCompletion = nil
        }
    }

    func clearCachedAuthResponse() {
        self.existingConnectOptions = nil
    }
}
