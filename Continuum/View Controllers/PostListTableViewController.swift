//
//  PostListTableViewController.swift
//  Continuum
//
//  Created by Madison Kaori Shino on 7/9/19.
//  Copyright © 2019 Madi S. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController {

    //PROPERTIES
    var isSearching: Bool = false
    var resultsArray: [Post] = []
    var dataSource: [Post]? {
        return isSearching ? resultsArray : PostController.sharedInstance.posts
    }
    
    //OUTLETS
    @IBOutlet weak var postSearchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postSearchBar.delegate = self
        
        let label = UILabel()
        label.text = "Not-Instagram"
        label.font = UIFont(name: "Sweet Hipster", size: 40)
        label.textColor = #colorLiteral(red: 0.8689501882, green: 0.2017516792, blue: 0.4479867816, alpha: 1)
        label.textAlignment = .center
        label.sizeToFit()
        let secondLabel = UILabel()
        secondLabel.text = "The Best Photo Sharing App"
        secondLabel.font = UIFont(name: "avenir", size: 15)
        secondLabel.textColor = UIColor.lightGray
        secondLabel.sizeToFit()
        
        let stackView = UIStackView(arrangedSubviews: [label, secondLabel])
        stackView.axis = .vertical
        stackView.frame.size.width = label.frame.width + secondLabel.frame.width
        stackView.frame.size.height = max(label.frame.height, secondLabel.frame.height)
        
        navigationItem.titleView = stackView
        sync(completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.resultsArray = PostController.sharedInstance.posts
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    //TABLE VIEW
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let dataSource = dataSource else { return 0 }
        return dataSource.count
    }
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postTableViewCell", for: indexPath) as? PostTableViewCell else { return UITableViewCell() }
        
        if let dataSource = dataSource {
            let post = dataSource[indexPath.row]
            cell.post = post
            cell.updateViews()
        }
        return cell
    }
    
    //NAVIGATION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPostDetailTableView" {
            guard let index = tableView.indexPathForSelectedRow,
                let dataSource = self.dataSource
            else { return }
            let destinationDTVC = segue.destination as? PostDetailTableViewController
            let post = dataSource[index.row]
            destinationDTVC?.postLandingPad = post
        }
    }
    
    //FUNCTIONS
    func sync(completion:((Bool) -> Void)?) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PostController.sharedInstance.fetchPosts { (posts) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                completion?(posts != nil)
            }
        }
    }
}

//SEARCH BAR EXTENSION
extension PostListTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            resultsArray = PostController.sharedInstance.posts
            tableView.reloadData()
        } else {
            resultsArray = PostController.sharedInstance.posts.filter {
                $0.matchesSearchTerm(searchTerm: searchText)
            }
            tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resultsArray = PostController.sharedInstance.posts
        tableView.reloadData()
        searchBar.text = ""
        self.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearching = false
    }
}

