//
//  ChatSwiftApp.swift
//  ChatSwift
//
//  Created by 小暮準才 on 2022/07/11.
//

import SwiftUI
import Firebase

@main
struct ChatSwiftApp: App {
    
        init() {
            FirebaseApp.configure()
            print("Firebase Connected")
        }
    
    var body: some Scene {
        WindowGroup {
            MainMessageView()
        }
    }
}
