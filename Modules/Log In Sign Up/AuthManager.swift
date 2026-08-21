//
//  AuthManager.swift
//  Movter
//
//  Created by Nurtore on 03.07.2026.
//

import Foundation
import FirebaseAuth

final class AuthManager {
    static let shared = AuthManager()
    private init() {}
    
    func signUp(withUserRequest request: RegisterUserRequest, completion: @escaping (Bool, Error?) -> Void) {
        Auth.auth().createUser(withEmail: request.email, password: request.password) { result, error in
            if let error = error {
                completion(false, error)
                return
            }
            if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                changeRequest.displayName = request.username
                changeRequest.commitChanges { _ in
                    completion(true, nil)
                }
            } else {
                completion(true, nil)
            }
        }
    }

    func logIn(withUserRequest request: LoginUserRequest, completion: @escaping (Bool, Error?) -> Void) {
        Auth.auth().signIn(withEmail: request.email, password: request.password) { result, error in
            if let error = error {
                completion(false, AuthManager.genericLoginError(from: error))
                return
            }
            completion(true, nil)
        }
    }

    // Collapses account-existence-revealing errors into one generic message so a failed
    // login can't be used to enumerate which emails have registered accounts. Other errors
    // (network failure, too many requests, disabled account, ...) pass through unchanged
    // since they aren't enumeration risks and the distinct messaging is useful to the user.
    private static func genericLoginError(from error: Error) -> Error {
        let nsError = error as NSError
        guard let code = AuthErrorCode(rawValue: nsError.code) else { return error }
        switch code {
        case .wrongPassword, .userNotFound, .invalidEmail, .invalidCredential:
            return NSError(domain: nsError.domain, code: nsError.code, userInfo: [NSLocalizedDescriptionKey: "Invalid email or password."])
        default:
            return error
        }
    }
}

struct RegisterUserRequest {
    let username: String
    let email: String
    let password: String 
}

struct LoginUserRequest {
    let email: String
    let password: String
}
