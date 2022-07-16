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

class MainMessageViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var isUserLoggeOut = false
    
    init() {
        
        DispatchQueue.main.async {
            self.isUserLoggeOut = (Auth.auth().currentUser?.uid == nil)
        }
        
        fetchCurrentUser()
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
                vm.signOutFirebase()
            }),
                     .cancel()
                    ])}.fullScreenCover(isPresented: $vm.isUserLoggeOut) {
                LoginView {
                    self.vm.isUserLoggeOut = false
                    self.vm.fetchCurrentUser()
                }
            }
        
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
    
    @State var showNewMessageScreen = false
    
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
            NewMessageView()
        }
    }
}


struct MainMessageView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessageView()
    }
}
