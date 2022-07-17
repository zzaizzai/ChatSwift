//
//  RecentMessage.swift
//  ChatSwift
//
//  Created by 小暮準才 on 2022/07/17.
//

import Foundation
import Firebase
import FirebaseFirestore


struct RecentMessage: Identifiable {
    
    var id: String { documentId }
    
    let documentId: String
    let text, email : String
    let fromId, toId: String
    let profileImageUrl: String
    let date: Date
    
    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        self.text = data["text"] as? String ?? ""
        self.fromId = data["fromId"] as? String ?? ""
        self.toId = data["toId"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.date = data["date"] as? Date ?? Date()
        
    }
}
