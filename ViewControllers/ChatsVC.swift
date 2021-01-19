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
    @IBOutlet weak var chatUserBarButton: UIBarButtonItem!
        
    var viewModel = ChatsViewModel()
    var cancellables = Set<AnyCancellable>()
    var channelAlertController: UIAlertController?
    private var chats = [Chat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        viewModel.reloadData = { [weak self] in
            print("reloading data")
            self?.tableView.reloadData()
        }
        
        let auth = Authentication.shared
        auth.$chatUser
            .sink { [weak self] (chatUser) in
                self?.chatUserBarButton.title = chatUser?.userName
            }.store(in: &cancellables)
        
        auth.signInIfNeeded()
        
    }
    
    @IBAction func addChat(_ sender: Any) {
        let alert = UIAlertController(title: "Chat", message: "Create a Chat", preferredStyle: UIAlertController.Style.alert)
        channelAlertController = alert
        
        alert.addTextField { (textField) in
            textField.addTarget(self,
                                action: #selector(self.textFieldChanged),
                                for: .editingChanged)
            textField.enablesReturnKeyAutomatically = true
            textField.placeholder = "Enter Chat Name"
        }
        
        let createAction = UIAlertAction(title: "Create",
                                      style: .default,
                                      handler: { [weak self] _ in
                                        self?.viewModel.createChat(alert: alert)
                                      })
        alert.addAction(createAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        
        alert.preferredAction = createAction
        present(alert, animated: true, completion: nil)
        
    }
    
    @objc func textFieldChanged(_ field: UITextField) {
        channelAlertController?.preferredAction?.isEnabled = field.hasText
    }

}

extension ChatsVC: UITableViewDelegate {
    
}

extension ChatsVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(viewModel.chats.count)
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

