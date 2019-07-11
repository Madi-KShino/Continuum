//
//  PostController.swift
//  Continuum
//
//  Created by Madison Kaori Shino on 7/9/19.
//  Copyright © 2019 Madi S. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

let publicDatabase = CKContainer.default().publicCloudDatabase

class PostController {
    
    //SINGLETON
    static let sharedInstance = PostController()
    
    //SOURCE OF TRUTH
    var posts: [Post] = []
    
    //CRUD FUNCTIONS
    
    func createPostWith(photo: UIImage, caption: String, completion: @escaping (Post?) -> Void) {
        let post = Post(caption: caption, photo: photo)
        posts.append(post)
        let record = CKRecord(post: post)
        CKContainer.default().publicCloudDatabase.save(record) { (record, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) /n---/n \(error)")
                completion(nil)
                return
            }
            guard let record = record,
                let post = Post(record: record) else { completion(nil); return}
            completion(post)
        }
    }
    
    func createCommentWith(text: String, post: Post, completion: @escaping (Comment?) -> Void) {
        let comment = Comment(text: text, post: post)
        post.comments.append(comment)
        let record = CKRecord(comment: comment)
        CKContainer.default().publicCloudDatabase.save(record) { (record, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) /n---/n \(error)")
                completion(nil)
                return
            }
            guard let record = record else { completion(nil); return }
            let comment = Comment(record: record, post: post)
            self.increaseCommentCount(post: post, completion: nil)
            completion(comment)
        }
    }
    
    func fetchPosts(completion: @escaping ([Post]?) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: PostConstants.typeKey, predicate: predicate)
        publicDatabase.perform(query, inZoneWith: nil) { (record, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) /n---/n \(error)")
                completion(nil)
                return
        }
            guard let record = record else { return }
            let posts = record.compactMap{Post(record: $0)}
            self.posts = posts
            completion(posts)
        }
    }
    
    func fetchComments(forPost post: Post, completion: @escaping ([Comment]?) -> Void) {
        let postReference = post.cloudKitRecordID
        let predicate = NSPredicate(format: "%K == %@", CommentConstants.postReferenceKey, postReference )
        let commentIDs = post.comments.compactMap({$0.recordID})
        let secondPredicate = NSPredicate(format: "NOT(recordID IN %@)", commentIDs)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, secondPredicate])
        let query = CKQuery(recordType: CommentConstants.commentTypeKey, predicate: compoundPredicate)
        publicDatabase.perform(query, inZoneWith: nil) { (record, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) /n---/n \(error)")
                completion(nil)
                return
        }
            guard let record = record else { return }
            let comments = record.compactMap{Comment(record: $0, post: post)}
            post.comments.append(contentsOf: comments)
            completion(comments)
        }
    }
    
    func increaseCommentCount(post: Post, completion: ((Bool)-> Void)?){
        post.commentCount += 1
        let modifyOperation = CKModifyRecordsOperation(recordsToSave: [CKRecord(post: post)], recordIDsToDelete: nil)
        modifyOperation.savePolicy = .changedKeys
        modifyOperation.modifyRecordsCompletionBlock = { (records, _, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) /n---/n \(error)")
                completion?(false)
                return
            }else {
                completion?(true)
            }
        }
        CKContainer.default().publicCloudDatabase.add(modifyOperation)
    }
}
