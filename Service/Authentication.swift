//
//  Authentication.swift
//  MessageApp
//
//  Created by Jay Muthialu on 1/17/21.
//

import Foundation
import Combine
import FirebaseAuth

class Authentication {
    
    struct Constants {
        static let chatUserKey = "chatUser"
    }
    
    static var shared = Authentication()
    
    @Published var chatUser: ChatUser?
    
    private init() {}
    
    func getChatUserIfLoggedIn() {
        let defaults = UserDefaults.standard
        if let data = defaults.object(forKey: Constants.chatUserKey) as? Data {
            do {
                let chatUser = try JSONDecoder().decode(ChatUser.self, from: data)
                self.chatUser = chatUser
            } catch {
                print("chatUser decoding error: \(error)")
            }
        } else {
            chatUser = nil
        }
    }

    func login(userName: String) {
        let defaults = UserDefaults.standard
        Auth.auth().signInAnonymously { [weak self] (result, error) in
            guard let result = result, error == nil else { return }
            let chatUser = ChatUser(userName: userName, userID: result.user.uid)
            do {
                let data = try JSONEncoder().encode(chatUser)
                defaults.set(data, forKey: Constants.chatUserKey)
                self?.chatUser = chatUser
            } catch {
                print("chatUser encoding error: \(error)")
            }
        }
    }
    
    func logoff() {
        do {
            try Auth.auth().signOut()
            chatUser = nil
            UserDefaults.standard.removeObject(forKey: Constants.chatUserKey)
        } catch {
            print("Logoff error: \(error)")
        }
    
    }
}
