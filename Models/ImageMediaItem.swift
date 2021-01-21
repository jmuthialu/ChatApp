//
//  ImageMediaItem.swift
//  MessageApp
//
//  Created by Jay Muthialu on 1/20/21.
//

import UIKit
import MessageKit

class ImageMediaItem: MediaItem {
    
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init() {
        self.placeholderImage = UIImage()
        self.size = CGSize.zero
    }
    
    init(url: URL, image: UIImage) {
        self.url = url
        self.image = image
        self.placeholderImage = image
        self.size = image.size
    }
}
