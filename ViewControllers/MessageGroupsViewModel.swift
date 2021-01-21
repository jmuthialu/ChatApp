//
//  MessageGroupsViewModel.swift
//  MessageApp
//
//  Created by Jay Muthialu on 1/17/21.
//

import Foundation
import Combine
import FirebaseFirestore

class MessageGroupsViewModel {
    
    var messageGroups = [MessageGroup]()
    var reloadData: (() -> Void)?
    
    let db = Firestore.firestore()
    private var messageGroupReference: CollectionReference {
        return db.collection("messageGroups")
    }
    private var messageGroupListener: ListenerRegistration?

    deinit {
        messageGroupListener?.remove()
    }
    
    func setupListeners() {
        messageGroupListener = messageGroupReference.addSnapshotListener{
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
        guard let groupName =
                alert?.textFields?.first?.text else { return }
        let group = MessageGroup(name: groupName)
        messageGroupReference.addDocument(data: group.toFireBaseModel) { error in
            if let error = error {
                print("Error adding chat: \(String(describing: error))")
            }
        }
    }
    
    func handleDocumentChange(change: DocumentChange) {
        let messageGroup = MessageGroup(document: change.document)
        switch change.type {
        case .added:
            messageGroups.append(messageGroup)
        default:
            break
        }
    }
    
    func login(alert: UIAlertController?) {
        guard let loginName = alert?.textFields?.first?.text else { return }
        Authentication.shared.login(userName: loginName)
    }
    
}

