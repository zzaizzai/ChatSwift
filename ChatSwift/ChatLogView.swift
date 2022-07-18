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
    
    @Published var chatMessages = [ChatMessages]()
    
    @Published var scrollCount = 0
    
    @Published var currentUser = [ChatUser]()
    
    
    
    var chatUser : ChatUser?
    
    
    init(chatUser: ChatUser?){
        self.chatUser = chatUser
        self.fetchMessages()
        
    }
    
    
    var firestoreListener: ListenerRegistration?
    
    func fetchMessages(){
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        
        firestoreListener?.remove()
        chatMessages.removeAll()
        
        firestoreListener = Firestore.firestore().collection("messages").document(fromId).collection(toId).order(by: "date").addSnapshotListener { querySnapshot, error in
            if let error = error {
                self.errorMessage = "Failed to get messages \(error)"
                print(error)
                return
                
            }
            
            querySnapshot?.documentChanges.forEach({ change in
                if change.type == .added {
                    let data = change.document.data()
                    self.chatMessages.append(.init(documentId: change.document.documentID, data: data))
                    self.scrollCount += 1
                }
            })
            
            //show latest message
            DispatchQueue.main.async {
                self.scrollCount += 1
            }
            
        }
    }
    
    func storeRercentMessage() {
        guard let chatUser = chatUser else { return }
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = self.chatUser?.uid else { return }
        guard let currentUser = FirebaseManager.shared.currentUser else {
            return }
        
        print(currentUser)
        
        
        
        let dataForMe = [
            "date": Timestamp(),
            "text":self.chatText,
            "fromId": uid,
            "toId": toId,
            "profileImageUrl": chatUser.profileImageUrl,
            "email": chatUser.email
        ] as [String : Any]
        
        Firestore.firestore().collection("recentMessages").document(uid).collection("messages").document(toId).setData(dataForMe) { error in
            if let error = error {
                self.errorMessage = "Failed to save recent message: \(error)"
                print("failed to save recent message: \(error)")
                return
            }
            print("stored recent data for me")
        }
        

        let dataForYou = [
            "date": Timestamp(),
            "text":self.chatText,
            "fromId": uid,
            "toId": toId,
            "profileImageUrl": currentUser.profileImageUrl,
            "email": currentUser.email
        ] as [String : Any]
        

        Firestore.firestore().collection("recentMessages").document(toId).collection("messages").document(currentUser.uid).setData(dataForYou) { error in
            if let error = error {
                self.errorMessage = "Failed to save recent message: \(error)"
                print("failed to save recent message: \(error)")
                return
            }
            print("stored recent data for you")
        }
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
                self.storeRercentMessage()
                
                self.chatText = ""
                self.errorMessage = ""
                

            }
        
        Firestore.firestore().collection("messages")
            .document(toId)
            .collection(fromId)
            .document()
            .setData(messageData) { error in
                if let error = error {
                    self.errorMessage = "Failed: \(error)"
                    return
                }
                print("sotred receiver message")
            }
        
    }
    
}

struct ChatLogView: View {
    
//    let chatUser: ChatUser?
//
//    init(chatUser: ChatUser?) {
//        self.chatUser = chatUser
//        self.vm = .init(chatUser: chatUser)
//
//    }
    
    @State var chatMessage = ""
    
    @ObservedObject var vm : ChatLogViewModel
    
    var body: some View {
        ZStack{
            
            messagesView
            Text(vm.errorMessage)
                .foregroundColor(Color.red)
            
            
            
        }
        .navigationTitle(vm.chatUser?.email ?? "chatopponent")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear{
            vm.firestoreListener?.remove()
        }
    }
    
    private var messagesView: some View {
        ScrollView{
            ScrollViewReader { ScrollViewProxy in
                VStack{
                    ForEach(vm.chatMessages) { message in
                        MessageView(message: message)
                    }
                    HStack{ Spacer() }
                        .id("Empty")
                }
                
                .onReceive(vm.$scrollCount) { _ in
                    withAnimation(.easeOut(duration: 0.5)){
                        ScrollViewProxy.scrollTo("Empty", anchor: .bottom)
                        
                    }
                    
                }
                
            }
            
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
                .autocapitalization(.none)
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

struct MessageView: View {
    
    var message: ChatMessages
    var body: some View {
        if message.fromId == Auth.auth().currentUser?.uid {
            HStack{
                Spacer()
                HStack{
                    
                    Text(message.text)
                        .foregroundColor(.white)
                    
                }
                .padding()
                .background(Color.gray)
                .cornerRadius(23)
                
            }
            .padding(.horizontal)
        } else {
            HStack{
                HStack{
                    
                    Text(message.text)
                        .foregroundColor(.black)
                    
                }
                .padding()
                .background(Color.white)
                .cornerRadius(23)
                
                Spacer()
                
            }
            .padding(.horizontal)
        }
    }
}

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
//        NavigationView{
//            //                        ChatLogView(chatUser: .init(data: ["uid":"123" ,"email": "124@gmail.com"]))
            MainMessageView()
//        }
    }
}
