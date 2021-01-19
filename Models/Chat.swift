//
//  Chat.swift
//  ChatApp
//
//  Created by Jay Muthialu on 1/17/21.
//

import Foundation
import Firebase

protocol FirebaseRepresentation {
    var toFireBaseModel: [String: Any] { get }
}


class Chat {
    
    var id: String? // This is Firebase ID
    var name = ""
    
    init(name: String?) {
        self.id = nil
        self.name = name ?? "No Name"
    }
    
    init(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let name = data["name"] as? String else {
            return
        }
        self.name = name
        self.id = document.documentID
    }
    
}

extension Chat: FirebaseRepresentation {
    
    var toFireBaseModel: [String : Any] {
        var json = ["name": self.name]
        if let id = self.id {
            json["id"] = id
        }
        return json
    }
    
}

extension Chat: Comparable {
    
    static func == (lhs: Chat, rhs: Chat) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Chat, rhs: Chat) -> Bool {
        return lhs.name < rhs.name
    }
    
}

