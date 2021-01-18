//
//  Channel.swift
//  ChatApp
//
//  Created by Jay Muthialu on 1/17/21.
//

import Foundation
import Firebase

protocol FirebaseRespresentation {
    
    var firRepresentation: [String: Any] { get }
}


class Channel {
    
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

extension Channel: FirebaseRespresentation {
    
    var firRepresentation: [String : Any] {
        var json = ["name": self.name]
        if let id = self.id {
            json["id"] = id
        }
        return json
    }
    
}

extension Channel: Comparable {
    
    static func == (lhs: Channel, rhs: Channel) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Channel, rhs: Channel) -> Bool {
        return lhs.name < rhs.name
    }
    
}

