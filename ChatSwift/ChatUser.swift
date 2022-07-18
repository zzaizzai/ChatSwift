//
//  ChatUser.swift
//  ChatSwift
//
//  Created by 小暮準才 on 2022/07/16.
//

import Foundation
import FirebaseFirestoreSwift

struct ChatUser:Codable, Identifiable {
    
    @DocumentID var id: String?
    let uid, email, profileImageUrl: String
    
}
