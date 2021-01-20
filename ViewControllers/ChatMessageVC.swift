//
//  ChatMessagesVC.swift
//  ChatApp
//
//  Created by Jay Muthialu on 1/19/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import MessageKit
// Part of MessageKit
import InputBarAccessoryView

class ChatMessageVC: MessagesViewController {
    
    var viewModel = ChatMessageViewModel()
    
    init(currentUser: ChatUser?, chat: Chat?) {
        viewModel.currentUser = currentUser
        viewModel.chat = chat
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.reloadData = { [weak self] in
            print("Reloading data : \(String(describing: self?.viewModel.chatMessages.count))")
            self?.viewModel.chatMessages.sort()
            self?.messagesCollectionView.reloadData()
            self?.messagesCollectionView.scrollToBottom(animated: true)
        }
        viewModel.setupListeners()
        setupMessageView()
        if let chatName = viewModel.chat?.name {
            navigationItem.title = chatName
        }
    }
    
    func setupMessageView() {
        maintainPositionOnKeyboardFrameChanged = true
        
        messageInputBar.inputTextView.tintColor = .label
        messageInputBar.sendButton.setTitleColor(.label, for: .normal)
        messageInputBar.delegate = self
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        scrollsToLastItemOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        showMessageTimestampOnSwipeLeft = true // default false
        
        // Hide the outgoing avatar (Image of sender and receiver)
        let layout = messagesCollectionView
            .collectionViewLayout as? MessagesCollectionViewFlowLayout

        layout?.setMessageOutgoingAvatarSize(.zero)
        layout?.setMessageIncomingAvatarSize(.zero)

    }
}


