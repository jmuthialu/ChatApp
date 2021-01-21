//
//  UIAlertController+Extension.swift
//  MessagingApp
//
//  Created by Jay Muthialu on 1/20/21.
//

import UIKit

extension UIAlertController {
    
    static func getTextViewAlert(title: String,
                                 message: String,
                                 target: Any,
                                 textFieldChanged: Selector,
                                 alertAction: ((UIAlertAction) -> Void)?) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        
        alert.addTextField { (textField) in
            textField.addTarget(target,
                                action: textFieldChanged,
                                for: .editingChanged)
            textField.enablesReturnKeyAutomatically = true
            textField.placeholder = message
        }
        
        let createAction = UIAlertAction(title: "Create",
                                      style: .default,
                                      handler: alertAction)
        createAction.isEnabled = false
        alert.addAction(createAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        
        alert.preferredAction = createAction
        return alert
    }
}
