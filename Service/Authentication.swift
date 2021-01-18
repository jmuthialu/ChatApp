//
//  Authentication.swift
//  ChatApp
//
//  Created by Jay Muthialu on 1/17/21.
//

import Foundation
import Combine
import FirebaseAuth

class Authentication {
    
    static var shared = Authentication()
    @Published var chatUser: ChatUser?
    
    private init() {}
    
    func signInIfNeeded() {
        guard let currentUser = Auth.auth().currentUser else {
            signInAnonymously()
            return
        }
        chatUser = ChatUser(firUser: currentUser)
    }

    func signInAnonymously() {
        Auth.auth().signInAnonymously { [weak self] (result, error) in
            guard let result = result, error == nil else { return }
            self?.chatUser = ChatUser(firUser: result.user)
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Signout error: \(error)")
        }
    
    }
}
