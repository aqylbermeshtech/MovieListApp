//
//  AuthManager.swift
//  MovieListApp
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
                completion(false, error)
                return
            }
            completion(true, nil)
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
