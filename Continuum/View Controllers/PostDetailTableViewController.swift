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
            DispatchQueue.main.async {
                self.updateViews()
            }
        }
    }
    
    //OUTLET
    @IBOutlet weak var postImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //ACTIONS
    @IBAction func commentButtonTapped(_ sender: Any) {
        presentAlert()
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
    }
    
    @IBAction func followButtonTapped(_ sender: Any) {
    }
    
    func updateViews() {
        postImageView.image = postLandingPad?.photo
        self.tableView.reloadData()
        
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
                PostController.sharedInstance.addCommentWith(text: commentText, post: post, completion: { (comment) in
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                })
            }
        }
        let cancelAction = UIAlertAction(title:"Cancel", style: .destructive)
        alertController.addAction(addCommentAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
}
