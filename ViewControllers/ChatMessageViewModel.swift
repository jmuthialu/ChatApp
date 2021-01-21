//
//  ChatMessageViewModel.swift
//  MessageApp
//
//  Created by Jay Muthialu on 1/19/21.
//

import Foundation
import Firebase
import FirebaseFirestore

class ChatMessageViewModel {
    
    var currentUser: ChatUser?
    var messageGroup: MessageGroup?
    var chatMessages = [ChatMessage]()
    
    var db = Firestore.firestore()
    var messageReference: CollectionReference?
    var messageListener: ListenerRegistration?
    var storageRootReference = Storage.storage().reference()
    
    var reloadData: (() -> Void)?
    
    deinit {
        messageListener?.remove()
    }
    
    func setupListeners() {
        guard let chatId = messageGroup?.id else { return }
        let messagePath = ["messageGroups", chatId, "chatMessages"].joined(separator: "/")
        messageReference = db.collection(messagePath)
        
        messageListener = messageReference?.addSnapshotListener {
            [weak self] (snapShot, error) in
            guard let snapShot = snapShot, error == nil else { return }
            
            snapShot.documentChanges.forEach { (documentChange) in
                self?.handleDocument(change: documentChange)
            }
            
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
            if let imageURLString = chatMessage.imageURL {
              guard let url = URL(string: imageURLString) else { return }
              downloadImageFromFirestore(at: imageURLString) { [weak self] (image) in
                  guard let image = image else { return }
                  let imageMediaItem = ImageMediaItem(url: url, image: image)
                  chatMessage.kind = .photo(imageMediaItem)
                  self?.chatMessages.append(chatMessage)
                  self?.reloadData?()
              }
            } else {
                chatMessages.append(chatMessage)
                reloadData?()
            }
        default:
            break
        }
    }
    
    func saveToFirebase(image: UIImage) {
        uploadImagetoFireStore(image: image) { [weak self] url in
            guard let currentUser = self?.currentUser else { return }
            let chatMessage = ChatMessage(chatUser: currentUser, imageURL: url, image: image)
            self?.saveToFirebase(chatMessage: chatMessage)
        }
    }
    
    func uploadImagetoFireStore(image: UIImage, completion: @escaping (URL) -> Void) {
        guard let groupName = messageGroup?.name,
              let data = image.jpegData(compressionQuality: 0.4) else { return }
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        // Hierarchical folder where folder is "group name" and
        // all images to that groups are stored under it
        let imageRef = storageRootReference.child(groupName).child(UUID().uuidString)
        imageRef.putData(data, metadata: metaData) { (metaData, error) in
            guard let _ = metaData, error == nil else { return }
            
            imageRef.downloadURL { (url, error) in
                guard let url = url, error == nil else { return }
                print("image url: \(url)")
                completion(url)
            }
        }
    }
    
    private func downloadImageFromFirestore(at url: String?, completion: @escaping (UIImage?) -> Void) {
        guard let url = url else { return }
        let storageRef = Storage.storage().reference(forURL: url)
        let megaByte = Int64(1 * 1024 * 1024)
      
        storageRef.getData(maxSize: megaByte) { imageData, error in
            guard let imageData = imageData, error == nil else {
              completion(nil)
              return
            }
            completion(UIImage(data: imageData))
      }
    }
    
}
