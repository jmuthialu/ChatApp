//
//  ChatMessage.swift
//  MessagingApp
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
    var imageURL: String?
    
    init(chatUser: ChatUser, content: String) {
        self.sender = chatUser
        self.messageId = UUID().uuidString
        self.kind = .text(content)
    }
    
    init(chatUser: ChatUser, imageURL: URL, image: UIImage) {
        self.sender = chatUser
        self.messageId = UUID().uuidString
        let imageMediaItem = ImageMediaItem(url: imageURL, image: image)
        self.kind = .photo(imageMediaItem)
        self.imageURL = imageURL.absoluteString
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
        if let url = data["url"] as? String {
            self.imageURL = url
            // This is dummy .photo object which will be fixed in handleDocument()
            self.kind = .photo(ImageMediaItem())
        } else if let content = data["content"] as? String {
            self.kind = .text(content)
        } else {
            self.kind = .text("Error at ChatMessage Snapshot")
        }
    }
}

extension ChatMessage: FirebaseRepresentation {
    
    var toFireBaseModel: [String : Any] {
        var json = [String: Any] ()
        json["senderId"] = self.sender.senderId
        json["senderName"] = self.sender.displayName
        json["messageId"] = self.messageId
        json["sentDate"] = self.sentDate
        
        switch self.kind {
        case let .text(content):
            json["content"] = content
        case let .photo(imageMedaItem):
            if let urlString = imageMedaItem.url?.absoluteString {
                json["url"] = urlString
            }
        default:
            break
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
