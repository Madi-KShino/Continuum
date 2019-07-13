//
//  PostDetailTableViewController.swift
//  Continuum
//
//  Created by Madison Kaori Shino on 7/9/19.
//  Copyright © 2019 Madi S. All rights reserved.
//

import UIKit


class PostDetailTableViewController: UITableViewController {

    var postLandingPad: Post? {
        didSet {
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    //OUTLET
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var photoCaptionlabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var buttonStackView: UIStackView!
    
    //LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let post = postLandingPad else { return }
        PostController.sharedInstance.fetchComments(forPost: post) { (_) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    //ACTIONS
    @IBAction func commentButtonTapped(_ sender: Any) {
        presentAlert()
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        guard let postPhoto = postLandingPad?.photo,
        let caption = postLandingPad?.caption
        else { return }
        let shareAlert = UIActivityViewController(activityItems: [postPhoto, caption], applicationActivities: nil)
        present(shareAlert, animated: true, completion: nil)
    }
    
    @IBAction func followButtonTapped(_ sender: Any) {
        guard let post = postLandingPad else { return }
        PostController.sharedInstance.toggleSubscription(post: post) { (success, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) /n---/n \(error)")
                return
            }
            self.updateFollowPostButton()
        }
    }
    
    @objc func updateViews() {
        guard let post = postLandingPad else { return }
        postImageView.image = post.photo
        photoCaptionlabel.text = post.caption
        updateFollowPostButton()
        self.tableView.reloadData()
    }
    
    func updateFollowPostButton() {
        guard let post = postLandingPad else { return }
        PostController.sharedInstance.checkPostSubscription(post: post) { (found) in
            DispatchQueue.main.async {
                let followButtonText = found ? "Unfollow" : "Follow"
                self.followButton.setTitle(followButtonText, for: .normal)
                self.buttonStackView.layoutIfNeeded()
            }
        }
    }

    //TABLE VIEW
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let post = postLandingPad else { return 0 }
        return post.comments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
        
        let comment = postLandingPad?.comments[indexPath.row]
        cell.textLabel?.text = comment?.text
        cell.detailTextLabel?.text = comment?.timeStamp.formatDate()
        
        return cell
    }
}

extension PostDetailTableViewController: UITextFieldDelegate {
    func presentAlert() {
        let alertController = UIAlertController(title: "Comment", message: "What would you like to say?", preferredStyle: .alert)
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "..."
            textField.autocorrectionType = .yes
            textField.autocapitalizationType = .sentences
            textField.delegate = self
        }
        let addCommentAction = UIAlertAction(title: "Send", style: .default) { (_) in
            guard let commentText = alertController.textFields?.first?.text,
                let post = self.postLandingPad
                else {return}
            if commentText != "" {
                PostController.sharedInstance.createCommentWith(text: commentText, post: post, completion: { (comment) in
                })
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        let cancelAction = UIAlertAction(title:"Cancel", style: .destructive)
        alertController.addAction(addCommentAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
}
