//
//  PostListTableViewController.swift
//  Continuum
//
//  Created by Madison Kaori Shino on 7/9/19.
//  Copyright © 2019 Madi S. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //TABLE VIEW
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PostController.sharedInstance.posts.count
    }
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postTableViewCell", for: indexPath) as? PostTableViewCell else { return UITableViewCell() }
        
        cell.post = PostController.sharedInstance.posts[indexPath.row]
        
        return cell
    }
    
    //NAVIGATION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPostDetailTableView" {
            guard let index = tableView.indexPathForSelectedRow,
            let destinationDTVC = segue.destination as? PostDetailTableViewController
            else { return }
            let post = PostController.sharedInstance.posts[index.row]
            destinationDTVC.postLandingPad = post
        }
    }
}
