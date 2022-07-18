//
//  NewMessageView.swift
//  ChatSwift
//
//  Created by 小暮準才 on 2022/07/16.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import SDWebImageSwiftUI

class NewMessageViewModel: ObservableObject {
    
    @Published var users = [ChatUser]()
    @Published var errorMessage = "error"
    
    init() {
        fetchAllUsers()
    }
    
    private func fetchAllUsers() {
        Firestore.firestore().collection("users").getDocuments { documentsSnapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch users: \(error)"
                print("failed to fetch users: \(error)")
                return
            }
            
            documentsSnapshot?.documents.forEach({ snapshot in
                let user = try? snapshot.data(as: ChatUser.self)
                if user?.uid != FirebaseManager.shared.auth.currentUser?.uid {
                    self.users.append(user!)
                }
                
            })
            
            self.errorMessage = "Fetched users"
        }
        
    }
}

struct NewMessageView: View {
    
    let selectedNewUser : (ChatUser) -> ()
    
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var vm = NewMessageViewModel()
    
    var body: some View {
        NavigationView{
            ScrollView{
                ForEach(vm.users) { user in
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        selectedNewUser(user)
                    } label: {
                        HStack{
                            WebImage(url: URL(string: user.profileImageUrl))
                                .resizable()
                                .frame(width: 50, height: 50)
                                .clipped()
                                .cornerRadius(50)
                            Text(user.email)
                                .foregroundColor(Color(.label))
                            Spacer()
                        }.padding(.horizontal)
                        Divider()
                            .padding(.vertical, 8)
                    }
                }
                
            }.navigationTitle("new message")
                .toolbar {
                    ToolbarItemGroup(placement: .navigation) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                            
                        } label: {
                            Text("Cancle")
                        }
                    }
                }
        }
    }
}

struct NewMessageView_Previews: PreviewProvider {
    static var previews: some View {
        NewMessageView(selectedNewUser: {_ in
            
        })
    }
}
