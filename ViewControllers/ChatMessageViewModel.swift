//
//  ChatMessageViewModel.swift
//  ChatApp
//
//  Created by Jay Muthialu on 1/19/21.
//

import Foundation
import Firebase
import FirebaseFirestore

class ChatMessageViewModel {
    
    var currentUser: ChatUser?
    var chat: Chat?
    var chatMessages = [ChatMessage]()
    
    var db = Firestore.firestore()
    var messageReference: CollectionReference?
    var messageListener: ListenerRegistration?
    
    var reloadData: (() -> Void)?
    
    deinit {
        messageListener?.remove()
    }
    
    func setupListeners() {
        
        guard let chatId = chat?.id else { return }
        let messagePath = ["chats", chatId, "messages"].joined(separator: "/")
        messageReference = db.collection(messagePath)
        
        messageListener = messageReference?.addSnapshotListener {
            [weak self] (snapShot, error) in
            guard let snapShot = snapShot, error == nil else { return }
            
            snapShot.documentChanges.forEach { (documentChange) in
                self?.handleDocument(change: documentChange)
            }
            self?.reloadData?()
        }
        
    }
    
    func saveToFirebase(chatMessage: ChatMessage) {
        messageReference?.addDocument(data: chatMessage.toFireBaseModel) { error in
            if let error = error {
                print("Error adding chatMessage: \(String(describing: error))")
            }
        }   
    }
    
    func handleDocument(change: DocumentChange) {
        let chatMessage = ChatMessage(document: change.document)
        switch change.type {
        case .added:
            chatMessages.append(chatMessage)
        default:
            break
        }
    }
    
    
}
