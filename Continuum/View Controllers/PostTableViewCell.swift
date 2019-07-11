//
//  PostTableViewCell.swift
//  Continuum
//
//  Created by Madison Kaori Shino on 7/9/19.
//  Copyright © 2019 Madi S. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    //OUTLETS
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postCaptionLabel: UILabel!
    @IBOutlet weak var postCommentLabel: UILabel!
    @IBOutlet weak var postCommentCountLabel: UILabel!
    @IBOutlet weak var postTimeLabel: UILabel!
    
    //PROPERTIES
    var post: Post? {
        didSet {
            DispatchQueue.main.async {
                self.updateViews()
            }
        }
    }
    
    //FUNCTIONS
    func updateViews() {
        guard let post = post else { return }
        postImageView.image = post.photo
        postCaptionLabel.text = post.caption
        postCommentCountLabel.text = "\(post.commentCount)"
        postTimeLabel.text = post.timeStamp.formatDate()
    }
}
