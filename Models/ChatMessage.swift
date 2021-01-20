//
//  ChatMessage.swift
//  ChatApp
//
//  Created by Jay Muthialu on 1/19/21.
//

import Foundation
import FirebaseFirestore
import MessageKit

class ChatMessage: MessageType {
    
    var sender: SenderType
    var messageId: String = ""
    var sentDate = Date()
    var kind: MessageKind
    
    init(chatUser: ChatUser, content: String) {
        self.sender = chatUser
        self.messageId = UUID().uuidString
        self.kind = .text(content)
    }
    
    init(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        let senderId = data["senderId"] as? String ?? "Nil Sender Id"
        let senderName = data["senderName"] as? String ?? "Nil Sender Name"
        
        self.sender = ChatUser(userName: senderName, userID: senderId)
        self.messageId = data["messageId"] as? String ?? "Nil messageId"
        if let timeStamp = data["sentDate"] as? Timestamp {
            self.sentDate = timeStamp.dateValue()
        }
        self.kind = .text(data["content"] as? String ?? "Nil content")
    }
}

extension ChatMessage: FirebaseRepresentation {
    
    var toFireBaseModel: [String : Any] {
        var json = [String: Any] ()
        json["senderId"] = self.sender.senderId
        json["senderName"] = self.sender.displayName
        json["messageId"] = self.messageId
        json["sentDate"] = self.sentDate
        if case let .text(content) = self.kind {
            json["content"] = content
        }
        return json
    }
}

extension ChatMessage: Comparable {
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.sentDate == rhs.sentDate
    }
    
    static func < (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
}
