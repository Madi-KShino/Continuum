//
//  PostController.swift
//  Continuum
//
//  Created by Madison Kaori Shino on 7/9/19.
//  Copyright © 2019 Madi S. All rights reserved.
//

import Foundation
import UIKit

class PostController {
    
    //SINGLETON
    static let sharedInstance = PostController()
    
    //SOURCE OF TRUTH
    var posts: [Post] = []
    
    //CRUD FUNCTIONS
    func addCommentWith(text: String, post: Post, completion: @escaping (Comment) -> Void) {
        let comment = Comment(text: text, post: post)
        post.comments.append(comment)
    }
    
    func createPostWith(photo: UIImage, caption: String, completion: @escaping (Post?) -> Void) {
        let post = Post(caption: caption, photo: photo)
        posts.append(post)
    }
    
    
}
