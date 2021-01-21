//
//  ChatMessageVC+Extension.swift
//  MessagingApp
//
//  Created by Jay Muthialu on 1/19/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import MessageKit
import InputBarAccessoryView

extension ChatMessageVC: InputBarAccessoryViewDelegate {
    
    @objc
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        guard let currentUser = viewModel.currentUser else { return }
        let chatMessage = ChatMessage(chatUser: currentUser, content: text)
        viewModel.saveToFirebase(chatMessage: chatMessage)
        inputBar.inputTextView.text = ""
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        text.count > 0 ? viewModel.updateBubbleState(state: true):
            viewModel.updateBubbleState(state: false)
    }
    
    func setTypingIndicatorViewHidden(chatBubble: ChatBubble) {
        guard let currentUserId = viewModel.currentUser?.senderId else { return }
        
        if chatBubble.senderId != currentUserId {
            setTypingIndicatorViewHidden(!chatBubble.state,
                                         animated: true,
                                         whilePerforming: nil)
            { [weak self] success in
                if success {
                    // Without this chat bubble will not be visible
                    self?.messagesCollectionView.scrollToLastItem(animated: true)
                }
            }
        }
    }
}

extension ChatMessageVC: MessagesDataSource {
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return 1
    }
    
    func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
        return viewModel.chatMessages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return viewModel.chatMessages[indexPath.row]
    }
    
    func currentSender() -> SenderType {
        return viewModel.currentUser!
    }
    
    // Style Message sent date as Time
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }

    // Style Message Read attribute
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(string: "Read", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
    }

    // Style Sender Name
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }

    // Style Message sent date as Date
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }

}

extension ChatMessageVC: MessagesLayoutDelegate {
    
    // Message Timestamp
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    // Read Receipts
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
    // Sender Name
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    // Date Stamp
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }

}

extension ChatMessageVC: MessagesDisplayDelegate {
 
    func messageStyle(for message: MessageType, at indexPath: IndexPath,
      in messagesCollectionView: MessagesCollectionView) -> MessageStyle {

      let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
      return .bubbleTail(corner, .curved)
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        guard let currentUser = viewModel.currentUser else { return  UIColor.systemGray }
        if message.sender.senderId == currentUser.senderId {
            return UIColor.systemBlue
        } else {
            return UIColor.tertiarySystemBackground
        }
    }
}
