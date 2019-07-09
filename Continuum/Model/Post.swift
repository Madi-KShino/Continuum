//
//  Post.swift
//  Continuum
//
//  Created by Madison Kaori Shino on 7/9/19.
//  Copyright © 2019 Madi S. All rights reserved.
//

import Foundation
import UIKit

class Comment {
 
    var text: String
    var timeStamp: Date
    weak var post: Post?
    
    init(text: String, timeStamp: Date = Date(), post: Post) {
        self.text = text
        self.timeStamp = timeStamp
        self.post = post
    }
}

class Post {
    
    var caption: String
    let timeStamp: Date
    var comments: [Comment]
    var photoData: Data?
    var photo: UIImage? {
        get {
            guard let photoData = photoData else { return nil }
            return UIImage(data: photoData)
        }
        set {
            photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    
    init(caption: String, timeStamp: Date = Date(), comments: [Comment] = [], photo: UIImage) {
        self.caption = caption
        self.timeStamp = timeStamp
        self.comments = comments
        self.photo = photo
    }
}
