//
//  AddPostTableViewController.swift
//  Continuum
//
//  Created by Madison Kaori Shino on 7/9/19.
//  Copyright © 2019 Madi S. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController {

    //OUTLETS
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var captionTextField: UITextField!
    
    var selectedImage: UIImage?
    
    //LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        addImageButton.setTitle("Select Image", for: .normal)
        postImageView.image = nil
        captionTextField.text = ""
    }
    
    //ACTIONS
    @IBAction func addImageButtonTapped(_ sender: Any) {
        addImageButton.setTitle("", for: .normal)
        postImageView.image = UIImage(named: "spaceEmptyState")
    }
    
    @IBAction func addPostButtonTapped(_ sender: Any) {
        guard let caption = captionTextField.text else { return }
        if postImageView.image != nil {
            guard let photo = postImageView.image else { return }
            PostController.sharedInstance.createPostWith(photo: photo, caption: caption) { (post) in
            }
                self.tabBarController?.selectedIndex = 0
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
    }
}
