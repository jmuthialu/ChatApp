//
//  UIImage+Helper.swift
//  MessagingApp
//
//  Created by Jay Muthialu on 1/21/21.
//

import UIKit

extension UIImage {
    
    // Compresses image size. Eg - Raw image size 3024x4032 compressed to 270x360
    func compressImage(maxLength: CGFloat) -> UIImage? {
          
        let largerSide: CGFloat = max(size.width, size.height)
        let ratio: CGFloat = largerSide > maxLength ? largerSide / maxLength : 1
        let newImageSize = CGSize(width: size.width / ratio, height: size.height / ratio)
        
        //draw image to new size
        defer {
          UIGraphicsEndImageContext()
        }
        UIGraphicsBeginImageContextWithOptions(newImageSize, true, 0)
        draw(in: CGRect(origin: .zero, size: newImageSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
//    func image(scaledTo size: CGSize) -> UIImage? {
//      defer {
//        UIGraphicsEndImageContext()
//      }
//
//      UIGraphicsBeginImageContextWithOptions(size, true, 0)
//      draw(in: CGRect(origin: .zero, size: size))
//
//      return UIGraphicsGetImageFromCurrentImageContext()
//    }
}
