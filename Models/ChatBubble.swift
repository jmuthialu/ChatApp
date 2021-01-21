//
//  ChatBubble.swift
//  MessagingApp
//
//  Created by Jay Muthialu on 1/21/21.
//

import Foundation
import FirebaseFirestore

class ChatBubble {
    
    var senderId: String = ""
    var state = false
    
    init() {}
    
    init(senderId: String, state: Bool) {
        self.senderId = senderId
        self.state = state
    }
    
    init(document: DocumentSnapshot?) {
        guard let data = document?.data() else { return }
        self.senderId = data["senderId"] as? String ?? "Nil Sender Id"
        self.state = data["state"] as? Bool ?? false
    }

}

extension ChatBubble: FirebaseRepresentation {

    var toFireBaseModel: [String : Any] {
        var json = [String: Any] ()
        json["senderId"] = self.senderId
        json["state"] = self.state
        return json
    }
}
