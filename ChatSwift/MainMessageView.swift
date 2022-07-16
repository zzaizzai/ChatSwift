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

struct ChatUser {
    let uid, email, profileImageUrl: String
}

class MainMessageViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    
    init() {
        fetchCurrentUser()
    }
    
    private func fetchCurrentUser() {
        
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
            let uid = data["uid"] as? String ?? ""
            let email = data["email"] as? String ?? ""
            let profileImageUrl = data["profileImageUrl"] as? String ?? ""
            self.chatUser = ChatUser(uid: uid, email: email, profileImageUrl: profileImageUrl)
            
            self.errorMessage = "\(data)"
            
        }
    }
}

struct MainMessageView: View {
    
    @State var showOptions = false
    @ObservedObject private var vm  = MainMessageViewModel()
    var body: some View {
        NavigationView{
            VStack{
                customNavBar
                
                messageView
                
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
                print("ddd")
            }),
                     .cancel()
                    ])}
        
    }
    
    private var messageView: some View {
        ScrollView{
            ForEach(0..<10, id: \.self){ num in
                VStack{
                    HStack(spacing: 16){
                        Image(systemName: "person.fill")
                            .font(.system(size: 32))
                        
                        VStack{
                            Text("username")
                                .font(.system(size: 16, weight: .bold))
                            Text("message")
                        }
                        Spacer()
                        Text("date")
                        
                    }
                    Divider()
                        .padding(.vertical, 8)
                    
                }.padding(.horizontal)
            }.padding(.bottom, 50)
        }
        
    }
    
    private var newMessageButton: some View {
        Button{
            print("newmessage")
            
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
    }
}


struct MainMessageView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessageView()
    }
}
