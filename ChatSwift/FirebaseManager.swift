//
//  FirebaseManager.swift
//  ChatSwift
//
//  Created by 小暮準才 on 2022/07/18.
//

import Foundation
import Firebase
import FirebaseFirestore

class FirebaseManager: NSObject {
    
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    
    var currentUser: ChatUser?
    
    static let shared = FirebaseManager()
    
    override init() {
        
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
    }
}
