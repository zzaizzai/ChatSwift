//
//  MainMessageView.swift
//  ChatSwift
//
//  Created by 小暮準才 on 2022/07/14.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import SDWebImageSwiftUI
import FirebaseFirestoreSwift

class MainMessageViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var isUserLoggeOut = false
    @Published var recentMessages = [RecentMessage]()
    
    init() {
        
        DispatchQueue.main.async {
            self.isUserLoggeOut = (Auth.auth().currentUser?.uid == nil)
        }
        
        fetchCurrentUser()
        
        fetchRecentMessages()
    }
    
    func fetchRecentMessages(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("recentMessages").document(uid).collection("messages").order(by: "date").addSnapshotListener { querySnapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch recent messages \(error)"
                return
            }
            querySnapshot?.documentChanges.forEach({ change in
                
                let docId = change.document.documentID
                
                if let index = self.recentMessages.firstIndex(where: { rm in
                    return rm.id == docId
                }) {
                    self.recentMessages.remove(at:index)
                    
                }
                
                do {
                    let rm = try change.document.data(as: RecentMessage.self)
                    self.recentMessages.insert(rm, at:0)
                    
                } catch {
                    print(error)
                    
                }
                
                
            })
        }
        
    }
    
    
    func signOutFirebase(){
        isUserLoggeOut.toggle()
        try? Auth.auth().signOut()
        
        
    }
    
    func fetchCurrentUser() {
        
        self.errorMessage = "fetching current user"
        guard let uid = Auth.auth().currentUser?.uid else {
            self.errorMessage = "cant get uid"
            return }
        
        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("Failed to fetch current user:", error)
                return
            }
            
            guard let data = snapshot?.data() else {
                self.errorMessage = "no data"
                return }
            
            self.chatUser = .init(data: data)
            
        }
    }
}

struct MainMessageView: View {
    
    @State var showOptions = false
    
    @State var showNavigateToChat = false
    @ObservedObject private var vm  = MainMessageViewModel()
    var body: some View {
        NavigationView{
            VStack{
                customNavBar
                
                messageView
                
                NavigationLink("???", isActive: $showNavigateToChat) {
                    ChatLogView(chatUser: self.chatUser)
                }
            }
            .overlay(
                newMessageButton, alignment: .bottom)
            .navigationBarHidden(true)
        }
    }
    
    private var customNavBar: some View {
        HStack{
            WebImage(url: URL(string: vm.chatUser?.profileImageUrl ?? "no profile"))
                .resizable()
                .scaledToFill()
                .frame(width: 53, height: 53)
                .clipped()
                .cornerRadius(44)
            
            VStack(alignment: .leading, spacing: 4){
                Text("\(vm.chatUser?.email ?? "no email")")
                    .font(.system(size:24, weight: .bold))
                Text("online")
            }
            Spacer()
            
            Button {
                showOptions.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.label))
            }
            
        }
        .padding()
        
        //options
        .actionSheet(isPresented: $showOptions) {
            .init(title: Text("setting"), message: Text("good"),
                  buttons:
                    [.destructive(Text("Sign Out"), action: {
                vm.signOutFirebase()
            }),
                     .cancel()
                    ])}
        .fullScreenCover(isPresented: $vm.isUserLoggeOut) {
                LoginView {
                    self.vm.isUserLoggeOut = false
                    self.vm.fetchCurrentUser()
                    self.vm.fetchRecentMessages()
                }
            }
        
    }
    
    private var messageView: some View {
        ScrollView{
            ForEach(vm.recentMessages){ recentMessage in
                VStack{
                    NavigationLink{
                        Text("dd")
                    } label: {
                        HStack(spacing: 16){
                            WebImage(url: URL(string: recentMessage.profileImageUrl ))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 53, height: 53)
                                .clipped()
                                .cornerRadius(44)
                            
                            VStack(alignment: .leading){
                                Text(recentMessage.email)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color.black)
                                Text(recentMessage.text)
                                    .foregroundColor(Color.gray)
                            }
                            Spacer()
                            VStack{
                                Text(recentMessage.date, style: .date)
                                Text(recentMessage.date, style: .time)
                                
                            }
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color.gray)
                            
                                
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                }.padding(.horizontal)
            }.padding(.bottom, 50)
        }
        
    }
    
    @State var showNewMessageScreen = false
    @State var chatUser: ChatUser?
    
    private var newMessageButton: some View {
        Button{
            showNewMessageScreen.toggle()
        } label: {
            HStack{
                Spacer()
                Text("new message")
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical)
            .background(Color.blue)
            .cornerRadius(32)
            .padding(.horizontal)
        }
        .fullScreenCover(isPresented: $showNewMessageScreen) {
            NewMessageView(selectedNewUser: {
                user in
                print(user.email)
                self.chatUser = user
                self.showNavigateToChat.toggle()
            })
        }
    }
}




struct MainMessageView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessageView()
    }
}
