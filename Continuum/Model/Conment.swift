//
//  Conment.swift
//  Continuum
//
//  Created by Madison Kaori Shino on 7/11/19.
//  Copyright © 2019 Madi S. All rights reserved.
//

import Foundation
import CloudKit

class Comment {
    
    //COMMENT PROPERTIES
    var text: String
    var timeStamp: Date
    var recordID: CKRecord.ID
    weak var post: Post?
   
    //COMMENT REFERENCE TO PARENT POST OBJECT
    var postReference: CKRecord.Reference? {
        guard let post = post else { return nil }
        return CKRecord.Reference(recordID: post.cloudKitRecordID, action: .deleteSelf)
    }
    
    //DESIGNATED/MEMBERWISE INIT
    init(text: String, timeStamp: Date = Date(), recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString) ,post: Post) {
        self.text = text
        self.timeStamp = timeStamp
        self.recordID = recordID
        self.post = post
    }
    
    //INIT COMMENT FROM RECORD
    convenience init?(record: CKRecord, post: Post) {
        guard let text = record[CommentConstants.textKey] as? String,
        let timeStamp = record[CommentConstants.timeStampKey] as? Date
            else { return nil }
        self.init(text: text, timeStamp: timeStamp, recordID: record.recordID, post: post)
    }
}

//SERCH BAR FUNCTIONALITY
extension Comment: SearchableRecord {
    func matchesSearchTerm(searchTerm: String) -> Bool {
        return text.lowercased() == searchTerm.lowercased() ? true : false
    }
}

//INIT RECORD
extension CKRecord {
    convenience init(comment: Comment) {
        self.init(recordType: CommentConstants.commentTypeKey, recordID: comment.recordID)
        self.setValue(comment.text, forKey: CommentConstants.textKey)
        self.setValue(comment.timeStamp, forKey: CommentConstants.timeStampKey)
        self.setValue(comment.postReference, forKey: CommentConstants.postReferenceKey)
    }
}

//RECORD KEY MAGIC STRINGS
struct CommentConstants {
    static let commentTypeKey = "Comment"
    fileprivate static let textKey = "text"
    fileprivate static let timeStampKey = "timeStamp"
    static let postReferenceKey = "post"
}
