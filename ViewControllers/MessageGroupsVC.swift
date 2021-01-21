//
//  MessageGroupsVC.swift
//  MessageApp
//
//  Created by Jay Muthialu on 1/17/21.
//

import UIKit
import Combine
import FirebaseAuth
import FirebaseFirestore

class MessageGroupsVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logActionButton: UIBarButtonItem!
    @IBOutlet weak var addChatButton: UIBarButtonItem!
    @IBOutlet weak var chatUserBarButton: UIBarButtonItem!
    
    var currentUser: ChatUser?
    var viewModel = MessageGroupsViewModel()
    var chatAlertController: UIAlertController?
    var loginAlertController: UIAlertController?
    
    var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        viewModel.reloadData = { [weak self] in
            self?.viewModel.messageGroups.sort()
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
            .getTextViewAlert(title: "Message Groups",
                              message: "Create a group",
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

extension MessageGroupsVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.messageGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath) as? GroupCell {
            cell.nameLabel.text = viewModel.messageGroups[indexPath.row].name
            return cell
        } else {
            return UITableViewCell()
        }
    }

}

extension MessageGroupsVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let messageGroup = viewModel.messageGroups[indexPath.row]
        let vc = ChatMessageVC(currentUser: currentUser, messageGroup: messageGroup)
        navigationController?.pushViewController(vc, animated: true)
    }
}

