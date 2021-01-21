//
//  ChatMessageVC+Camera.swift
//  MessageApp
//
//  Created by Jay Muthialu on 1/20/21.
//

import UIKit

extension ChatMessageVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        if let image = info[.originalImage] as? UIImage {
            viewModel.saveToFirebase(image: image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
