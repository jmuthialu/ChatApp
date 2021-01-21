//
//  ChatMessagesVC.swift
//  MessagingApp
//
//  Created by Jay Muthialu on 1/19/21.
//

import UIKit
import Combine
import Firebase
import FirebaseFirestore
import MessageKit
// Part of MessageKit
import InputBarAccessoryView

class ChatMessageVC: MessagesViewController {
    
    var viewModel = ChatMessageViewModel()
    var cancellables = Set<AnyCancellable>()
    
    init(currentUser: ChatUser?, messageGroup: MessageGroup?) {
        viewModel.currentUser = currentUser
        viewModel.messageGroup = messageGroup
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
        
        viewModel.$chatBubble
            .sink { [weak self] (chatBubble) in
                self?.setTypingIndicatorViewHidden(chatBubble: chatBubble)
            }.store(in: &cancellables)
        
        viewModel.setupListeners()
        viewModel.setBubbleStateInFirebase()
        configureMessageView()
        if let chatName = viewModel.messageGroup?.name {
            navigationItem.title = chatName
        }
    }
    
    func configureMessageView() {
        maintainPositionOnKeyboardFrameChanged = true
        
        messageInputBar.inputTextView.tintColor = .label
        messageInputBar.sendButton.setTitleColor(.label, for: .normal)
        messageInputBar.separatorLine.isHidden = false
        messageInputBar.inputTextView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        messageInputBar.inputTextView.layer.borderWidth = 1.0
        messageInputBar.inputTextView.layer.cornerRadius = 16.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.sendButton.setTitleColor(.systemBlue, for: .normal)
        
        // Setup delegates
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
        
        // Adding camera button
        let cameraItem = InputBarButtonItem(type: .system)
        cameraItem.tintColor = .darkGray
        cameraItem.image = UIImage(systemName: "camera.on.rectangle.fill")
        cameraItem.addTarget(
          self,
          action: #selector(cameraButtonPressed),
          for: .primaryActionTriggered
        )
        cameraItem.setSize(CGSize(width: 60, height: 30), animated: false)

        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setLeftStackViewWidthConstant(to: 60, animated: false)
        messageInputBar.setStackViewItems([cameraItem], forStack: .left, animated: false)

    }
    
    @objc func cameraButtonPressed() {
        let picker = UIImagePickerController()
        picker.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary // Sim does not have camera so open photos
        }
        viewModel.updateBubbleState(state: true)
        present(picker, animated: true, completion: nil)
    }
}



