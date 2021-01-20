//
//  ChatsVC.swift
//  ChatApp
//
//  Created by Jay Muthialu on 1/17/21.
//

import UIKit
import Combine
import FirebaseAuth
import FirebaseFirestore

class ChatsVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logActionButton: UIBarButtonItem!
    @IBOutlet weak var addChatButton: UIBarButtonItem!
    @IBOutlet weak var chatUserBarButton: UIBarButtonItem!
    
    var currentUser: ChatUser?
    var viewModel = ChatsViewModel()
    var chatAlertController: UIAlertController?
    var loginAlertController: UIAlertController?
    
    var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        viewModel.reloadData = { [weak self] in
            self?.viewModel.chats.sort()
            self?.tableView.reloadData()
        }
        viewModel.setupListeners()

        let auth = Authentication.shared
        auth.$chatUser
            .sink { [weak self] (chatUser) in
                self?.currentUser = chatUser
                self?.chatUserBarButton.title = chatUser?.displayName
                self?.updateUIForLogin(chatUser: chatUser)
            }.store(in: &cancellables)
        
        auth.getChatUserIfLoggedIn()
        navigationItem.backBarButtonItem = UIBarButtonItem()
    }
    
    @IBAction func addChat(_ sender: Any) {
        let alert = UIAlertController
            .getTextViewAlert(title: "Chat",
                              message: "Create a chat",
                              target: self,
                              textFieldChanged: #selector(chatTextFieldChanged))
            { [weak self] (_) in
            self?.viewModel.saveChatToFirebase(alert: self?.chatAlertController)
        }
        
        chatAlertController = alert
        present(alert, animated: true, completion: nil)
    }

    @IBAction func logAction(_ sender: Any) {
        if let _ = currentUser {
            Authentication.shared.logoff()
        } else {
            showLoginAlert()
        }
    }
    
    func showLoginAlert() {
        let alert = UIAlertController
            .getTextViewAlert(title: "Login",
                              message: "Enter user name",
                              target: self,
                              textFieldChanged: #selector(loginTextFieldChanged))
            { [weak self] (_) in
                self?.viewModel.login(alert: self?.loginAlertController)
        }
        
        loginAlertController = alert
        present(alert, animated: true, completion: nil)
        
    }
    @objc func loginTextFieldChanged(_ field: UITextField) {
        loginAlertController?.preferredAction?.isEnabled = field.hasText
    }

    @objc func chatTextFieldChanged(_ field: UITextField) {
        chatAlertController?.preferredAction?.isEnabled = field.hasText
    }
    
    func updateUIForLogin(chatUser: ChatUser?) {
        if let _ = chatUser { // user logged in
            logActionButton.title = "Logoff"
            tableView.isHidden = false
            addChatButton.isEnabled = true
        } else {
            logActionButton.title = "Login"
            tableView.isHidden = true
            addChatButton.isEnabled = false
        }
    }
    
}

extension ChatsVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chat = viewModel.chats[indexPath.row]
        let vc = ChatMessageVC(currentUser: currentUser, chat: chat)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ChatsVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as? ChatCell {
            cell.nameLabel.text = viewModel.chats[indexPath.row].name
            return cell
        } else {
            return UITableViewCell()
        }
    }

}

