//
//  ChannelViewModel.swift
//  ChatApp
//
//  Created by Jay Muthialu on 1/17/21.
//

import Foundation
import Combine
import FirebaseFirestore

class ChannelViewModel {
    
    var channels = [Channel]()
    var reloadData: (() -> Void)?
    
    let db = Firestore.firestore()
    private var channelReference: CollectionReference {
        return db.collection("channels")
    }
    private var channelListener: ListenerRegistration?

    init() {
        channelListener = channelReference.addSnapshotListener({ (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Channel snapshot error: \(String(describing: error))")
                return
            }
            snapshot.documentChanges.forEach { [weak self] (change) in
                self?.handleDocumentChange(change: change)
            }
        })
    }
    
    func handleDocumentChange(change: DocumentChange) {
        
        let channel = Channel(document: change.document)
        switch change.type {
        case .added:
            channels.append(channel)
            channels.sort()
            reloadData?()
            print(channels)
        default:
            break
        }
    }
    
    func createChannel(alert: UIAlertController) {
        guard let channelName =
                alert.textFields?.first?.text else { return }
        let channel = Channel(name: channelName)
        channelReference.addDocument(data: channel.firRepresentation) { error in
            if let error = error {
                print("Error adding channel: \(String(describing: error))")
            }
        }
    }
    
}
