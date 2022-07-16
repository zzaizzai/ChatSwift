//
//  ChatLogView.swift
//  ChatSwift
//
//  Created by 小暮準才 on 2022/07/17.
//

import SwiftUI
import Firebase
import FirebaseFirestore

class ChatLogViewModel: ObservableObject {
    
    @Published var chatText = ""
    @Published var errorMessage = ""
    
    let chatUser : ChatUser?
    
    
    init(chatUser: ChatUser?){
        self.chatUser = chatUser
        
    }
    
    func sendMessage(text: String) {

        print("to:", chatUser?.uid ?? "from uid")
        print("text", chatText)
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        print("from:", fromId)
//
//
        let messageData = ["fromId": fromId,
                           "toId": toId,
                           "text": self.chatText,
                           "date" : Timestamp() ] as [String: Any]
//
        Firestore.firestore().collection("messages")
            .document(fromId)
            .collection(toId)
            .document()
            .setData(messageData) { error in
                if let error = error {
                    self.errorMessage = "Failed: \(error)"
                    return
                }
                print("sended a message")
                self.chatText = ""
                self.errorMessage = ""
            }
        
        
        
        
    }
}

struct ChatLogView: View {
    
    let chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        self.vm = .init(chatUser: chatUser)
        
    }
    
    @State var chatMessage = ""
    
    @ObservedObject var vm : ChatLogViewModel
    
    var body: some View {
        ZStack{
            
            messagesView
            Text(vm.errorMessage)
                .foregroundColor(Color.red)
            
            
            
        }
        .navigationTitle(chatUser?.email ?? "chatopponent")
            .navigationBarTitleDisplayMode(.inline)
    }
    
    private var messagesView: some View {
        ScrollView{
            ForEach(0..<20) {num in
                HStack{
                    Spacer()
                    HStack{
                        
                        Text("messages")
                            .foregroundColor(.white)
                        
                    }
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(23)
                    
                }
                .padding(.horizontal)
            }
            
            HStack{ Spacer() }
            
        }
        .background(Color(.init(gray: 0.7, alpha: 1)))
        .safeAreaInset(edge: .bottom) {
            chatBottom
                .background(Color(
                    .systemBackground)
                    .ignoresSafeArea())
        }
    }
    
    private var chatBottom: some View {
        HStack(spacing: 16){
            Image(systemName: "photo")
            TextField("hello", text: $vm.chatText)
            Button {
                vm.sendMessage(text: vm.chatText)
            } label: {
                Text("send")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.gray)
            .cornerRadius(12)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            ChatLogView(chatUser: .init(data: ["uid":"123" ,"email": "124@gmail.com"]))
        }
    }
}
