//
//  ChatUser.swift
//  ChatApp
//
//  Created by Jay Muthialu on 1/17/21.
//

import Foundation
import FirebaseAuth

class ChatUser {
    var userName = ""
    var firUser: User?
    
    init(userName: String? = "Jay", firUser: User?) {
        self.userName = userName ?? "Nil UserName"
        self.firUser = firUser
    }
    
}
