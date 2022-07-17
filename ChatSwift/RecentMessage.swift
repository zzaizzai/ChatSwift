//
//  RecentMessage.swift
//  ChatSwift
//
//  Created by 小暮準才 on 2022/07/17.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift


struct RecentMessage: Codable, Identifiable {
    
    @DocumentID var id: String?
    
    let text, email : String
    let fromId, toId: String
    let profileImageUrl: String
    let date: Date
    
}
