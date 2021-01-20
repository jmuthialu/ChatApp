//
//  ChatUser.swift
//  ChatApp
//
//  Created by Jay Muthialu on 1/17/21.
//

import Foundation
import FirebaseAuth
import MessageKit

/// This serves as the user who sends and receives message.
/// Codable is added so that the object can be store in UserDefaults

class ChatUser: SenderType, Codable {
    
    var senderId: String
    var displayName: String
    
    init(userName: String, userID: String) {
        self.senderId = userID 
        self.displayName = userName
    }
    
}
