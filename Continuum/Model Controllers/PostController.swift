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
    private init() {
        subscribeToNewPosts(completion: nil)
    }
    
    //SOURCE OF TRUTH
    var posts: [Post] = []
    
    //CRUD FUNCTIONS
    
    func createPostWith(photo: UIImage, caption: String, completion: @escaping (Post?) -> Void) {
        let post = Post(caption: caption, photo: photo)
        self.posts.append(post)
        let record = CKRecord(post: post)
        publicDatabase.save(record) { (record, error) in
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
        publicDatabase.save(record) { (record, error) in
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
            guard let record = record else { completion(nil); return }
            let posts = record.compactMap{Post(record: $0)}
            self.posts.append(contentsOf: posts)
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
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) /n---/n \(error)")
                completion(nil)
                return
        }
            guard let records = records else { return }
            let comments = records.compactMap{Comment(record: $0, post: post)}
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
    
    func subscribeToNewPosts(completion: ((Bool, Error?) -> Void)?) {
        let predicate = NSPredicate(value: true)
        let subsription = CKQuerySubscription(recordType: PostConstants.typeKey, predicate: predicate, subscriptionID: "AllPosts", options: CKQuerySubscription.Options.firesOnRecordCreation)
        let notification = CKSubscription.NotificationInfo()
        notification.alertBody = "Check out the new posts!"
        notification.shouldBadge = true
        notification.shouldSendContentAvailable = true
        subsription.notificationInfo = notification
        publicDatabase.save(subsription) { (subscription, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) /n---/n \(error)")
                completion?(false, error)
                return
            } else {
                completion?(true, nil)
            }
        }
    }
    
    func subscribeToNewComments(post: Post, completion: ((Bool, Error?) -> Void)?) {
        let postRecordID = post.cloudKitRecordID
        let predicate = NSPredicate(format: "%K = %@", CommentConstants.postReferenceKey, postRecordID)
        let subsciption = CKQuerySubscription(recordType: CommentConstants.commentTypeKey, predicate: predicate, subscriptionID: post.cloudKitRecordID.recordName, options: CKQuerySubscription.Options.firesOnRecordCreation)
        let notification = CKSubscription.NotificationInfo()
        notification.alertBody = "Check out the new comment to a post you followed!"
        notification.shouldSendContentAvailable = true
        notification.desiredKeys = nil
        subsciption.notificationInfo = notification
        publicDatabase.save(subsciption) { (_, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) /n---/n \(error)")
                completion?(false, error)
            } else {
                completion?(true, nil)
            }
        }
    }
    
    func removeCommentSubscriptions(post: Post, completion: ((Bool) -> ())?) {
        let subscriptionID = post.cloudKitRecordID.recordName
        publicDatabase.delete(withSubscriptionID: subscriptionID) { (_, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) /n---/n \(error)")
                completion?(false)
                return
            } else {
                print("Subscription Deleted")
                completion?(true)
            }
        }
    }
    
    func checkPostSubscription(post: Post, completion: ((Bool) -> ())?) {
        let subscriptionID = post.cloudKitRecordID.recordName
        publicDatabase.fetch(withSubscriptionID: subscriptionID) { (subscription, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) /n---/n \(error)")
                completion?(false)
                return
            }
            if subscription != nil{
                completion?(true)
            } else {
                completion?(false)
            }
        }
    }
    
    func toggleSubscription(post: Post, completion: ((Bool, Error?) -> ())?) {
        checkPostSubscription(post: post) { (isSubscribed) in
            if isSubscribed {
                self.removeCommentSubscriptions(post: post, completion: { (success) in
                    if success {
                        print("Removed Subscription to post with caption \(post.caption)")
                        completion?(true, nil)
                    } else {
                        print("Error while removing subscription to post with caption \(post.caption)")
                        completion?(false, nil)
                    }
                })
            } else {
                self.subscribeToNewComments(post: post) { (success, error) in
                    if let error = error {
                        print("Error in \(#function): \(error.localizedDescription) /n---/n \(error)")
                        completion?(false, error)
                        return
                    }
                    if success {
                        print("Successfully subscribed to the post with captio \(post.caption)")
                        completion?(true, nil)
                    } else {
                        print("Error while adding subscription to post with caption \(post.caption)")
                        completion?(false, nil)
                    }
                }
            }
        }
    }
}
