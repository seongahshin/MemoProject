//
//  MemoModel.swift
//  MemoProject
//
//  Created by 신승아 on 2022/09/01.
//

import UIKit
import RealmSwift

class MemoModel: Object {
    
    @Persisted var title: String
    @Persisted var content: String?
    @Persisted var rawContent: String
    @Persisted var date = Date()
//    @Persisted var clicked = false
    
    @Persisted(primaryKey: true) var objectId: ObjectId
    
    convenience init(title: String, content: String, rawContent: String, date: Date) {
        self.init()
        self.title = title
        self.content = content
        self.rawContent = rawContent
        self.date = date
    }
}
