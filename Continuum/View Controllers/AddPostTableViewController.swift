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
    
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var captionTextView: UITextView!
    
    var selectedImage: UIImage?
    
    //LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //VIEW EDITING
        postButton.isEnabled = false
        updatePostButton()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    //ACTIONS
    @IBAction func addPostButtonTapped(_ sender: Any) {
        guard let photo = selectedImage,
            let caption = captionTextView.text else { return }
        if captionTextView.text == "" {
            let alertController = UIAlertController(title: "No Caption", message: "This photo doesn't have a caption yet, are you sure you want to continue?", preferredStyle: .alert)
            let addCaptionAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let saveWithoutCaptionAction = UIAlertAction(title: "Continue", style: .default) { (_) in
                PostController.sharedInstance.createPostWith(photo: photo, caption: caption) { (post) in }
                self.postButton.isEnabled = false
                self.selectedImage = nil
                self.captionTextView.text = ""
                self.updatePostButton()
                self.tabBarController?.selectedIndex = 0
            }
            alertController.addAction(saveWithoutCaptionAction)
            alertController.addAction(addCaptionAction)
            present(alertController, animated: true)
        } else {
            PostController.sharedInstance.createPostWith(photo: photo, caption: caption) { (post) in }
            self.postButton.isEnabled = false
            self.selectedImage = nil
            self.captionTextView.text = ""
            self.updatePostButton()
            self.tabBarController?.selectedIndex = 0
//            deinit{
//                
//            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        postButton.isEnabled = false
        selectedImage = nil
        captionTextView.text = ""
        updatePostButton()
        self.tabBarController?.selectedIndex = 0
    }
    
    //NAVIGATION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toContainerViewController" {
            let destinationContainerVC = segue.destination as? PhotoSelectorViewController
            destinationContainerVC?.delegate = self
        }
    }
    
    //VIEW EDITING
    func updatePostButton() {
        let image = selectedImage
        if image == nil {
            postButton.isEnabled = false
            postButton.setTitleColor(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), for: .normal)
        } else {
            postButton.isEnabled = true
            postButton.setTitleColor(#colorLiteral(red: 0.8689501882, green: 0.2017516792, blue: 0.4479867816, alpha: 1), for: .normal)
        }
    }
}

//IMAGE PICKER EXTENSION
extension AddPostTableViewController: PhotoSelectorViewControllerDelegate {
    func photoSelectorViewControllerSelected(image: UIImage) {
        selectedImage = image
        updatePostButton()
    }
}

