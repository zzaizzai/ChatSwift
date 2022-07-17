//
//  ChatMessages.swift
//  ChatSwift
//
//  Created by 小暮準才 on 2022/07/17.
//

import Foundation


struct ChatMessages: Identifiable {
    
    var id: String { documentId }
    
    let documentId: String
    let fromId, toId, text: String
    
    init(documentId: String, data: [String:Any]){
        self.documentId = documentId
        self.fromId = data["fromId"] as? String ?? ""
        self.toId = data["toId"] as? String ?? ""
        self.text = data["text"] as? String ?? ""
    }
}
