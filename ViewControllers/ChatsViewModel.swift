//
//  ChatsViewModel.swift
//  ChatApp
//
//  Created by Jay Muthialu on 1/17/21.
//

import Foundation
import Combine
import FirebaseFirestore

class ChatsViewModel {
    
    var chats = [Chat]()
    var reloadData: (() -> Void)?
    
    let db = Firestore.firestore()
    private var chatReference: CollectionReference {
        return db.collection("chats")
    }
    private var chatListener: ListenerRegistration?

    deinit {
        chatListener?.remove()
    }
    
    func setupListeners() {
        chatListener = chatReference.addSnapshotListener{
            [weak self] (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Chat snapshot error: \(String(describing: error))")
                return
            }
            snapshot.documentChanges.forEach { [weak self] (change) in
                self?.handleDocumentChange(change: change)
            }
            self?.reloadData?()
        }
    }
    
    func saveChatToFirebase(alert: UIAlertController?) {
        guard let chatName =
                alert?.textFields?.first?.text else { return }
        let chat = Chat(name: chatName)
        chatReference.addDocument(data: chat.toFireBaseModel) { error in
            if let error = error {
                print("Error adding chat: \(String(describing: error))")
            }
        }
    }
    
    func handleDocumentChange(change: DocumentChange) {
        let chat = Chat(document: change.document)
        switch change.type {
        case .added:
            chats.append(chat)
        default:
            break
        }
    }
    
    func login(alert: UIAlertController?) {
        guard let loginName = alert?.textFields?.first?.text else { return }
        Authentication.shared.login(userName: loginName)
    }
    
}
