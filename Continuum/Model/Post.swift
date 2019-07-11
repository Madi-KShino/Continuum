//
//  Post.swift
//  Continuum
//
//  Created by Madison Kaori Shino on 7/9/19.
//  Copyright © 2019 Madi S. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class Post {
    
    //POST PROPERTIES
    var caption: String
    let timeStamp: Date
    var comments: [Comment]
    var photoData: Data?
    var photo: UIImage? {
        get {
            guard let photoData = photoData else { return nil }
            return UIImage(data: photoData)
        }
        set {
            photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    var cloudKitRecordID: CKRecord.ID
    
    //IMAGE
    var imageAsset: CKAsset? {
        get {
            let tempDirectory = NSTemporaryDirectory()
            let tempDirecotryURL = URL(fileURLWithPath: tempDirectory)
            let fileURL = tempDirecotryURL.appendingPathComponent(cloudKitRecordID.recordName).appendingPathExtension("jpg")
            do {
                try photoData?.write(to: fileURL)
            } catch let error {
                print("Error writing to temp url \(error) \(error.localizedDescription)")
            }
            return CKAsset(fileURL: fileURL)
        }
    }
    
    //DESIGNATED/MEMBERWISE INIT
    init(caption: String, timeStamp: Date = Date(), comments: [Comment] = [], photo: UIImage, cloudKitRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.caption = caption
        self.timeStamp = timeStamp
        self.comments = comments
        self.cloudKitRecordID = cloudKitRecordID
        self.photo = photo
    }
    
    //INIT POST FROM RECORD
    init?(record: CKRecord) {
        guard let caption = record[PostConstants.captionKey] as? String,
        let timeStamp = record[PostConstants.timeStampKey] as? Date,
        let comments = record[PostConstants.commentsKey] as? [Comment],
        let imageAsset = record[PostConstants.photoKey] as? CKAsset
            else { return nil }
        self.caption = caption
        self.timeStamp = timeStamp
        self.comments = comments
        self.cloudKitRecordID = record.recordID
        
        do {
            try self.photoData = Data(contentsOf: imageAsset.fileURL!)
        } catch {
            print("error")
        }
    }
}

//SEARCH BAR FUNCTIONALITY EXTENSION
extension Post: SearchableRecord {
    func matchesSearchTerm(searchTerm: String) -> Bool {
        if caption.lowercased().contains(searchTerm.lowercased()) {
            return true
        } else {
            for comment in comments {
                if comment.text.lowercased().contains(searchTerm.lowercased()) {
                    return true
                }
            }
        }
        return false
    }
}

//RECORD INIT
extension CKRecord {
    convenience init(post: Post) {
        self.init(recordType: PostConstants.typeKey, recordID: post.cloudKitRecordID)
        self.setValue(post.caption, forKey: PostConstants.captionKey)
        self.setValue(post.timeStamp, forKey: PostConstants.timeStampKey)
        self.setValue(post.comments, forKey: PostConstants.commentsKey)
        self.setValue(post.imageAsset, forKey: PostConstants.photoKey)
    }
}

//RECORD KEY MAGIC STRINGS
struct PostConstants {
    static let typeKey = "Post"
    fileprivate static let captionKey = "caption"
    fileprivate static let timeStampKey = "timeStamp"
    fileprivate static let commentsKey = "comments"
    fileprivate static let photoKey = "photo"
}
