//
//  ContentView.swift
//  ChatSwift
//
//  Created by 小暮準才 on 2022/07/11.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct LoginView: View {
    
    let didloginProcess: () -> ()
    
    @State private var isLoginMode = true
    @State private var email = ""
    @State private var password = ""
    @State private var passwordCheck = ""
    @State private var errorMessage = ""
    @State private var successMessage = ""
    @State private var showImagePicker = false
    @State private var image: UIImage?
    
    
    var body: some View {
        NavigationView{
            ScrollView{
                
                VStack{
                    
                    Picker(selection: $isLoginMode, label: Text("good")) {
                        Text("login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                            .onChange(of: isLoginMode) { _ in
                                self.cleanTextfileds()
                            }
                    }.pickerStyle(SegmentedPickerStyle())
                        .padding()
                    
                    if !isLoginMode {
                        Button{
                            self.showImagePicker.toggle()
                            
                        } label: {
                            ZStack{
                                if let image = self.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: 128, height: 128)
                                        .scaledToFill()
                                        .cornerRadius(64)
                                        .overlay(RoundedRectangle(cornerRadius: 64)
                                            .stroke(Color.black, lineWidth: 3))
                                } else {
                                    Image(systemName: "photo")
                                        .font(.system(size: 64))
                                        .padding()
                                        .foregroundColor(Color(.label))
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                    Group {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        TextField("Password", text: $password)
                            .autocapitalization(.none)
                        
                        if !isLoginMode {
                            TextField("PasswordCheck", text: $passwordCheck)
                                .autocapitalization(.none)
                        }
                    }.padding(12)
                        .background(Color.white)
                    
                    
                    Button{
                        loginOrCreateAccount()
                        
                    } label: {
                        HStack{
                            Spacer()
                            if isLoginMode {
                                Text("Log In")
                                    .foregroundColor(.white)
                                    .padding(.vertical, 10)
                            } else {
                                Text("Create Account")
                                    .foregroundColor(.white)
                                    .padding(.vertical, 10)
                            }
                            Spacer()
                        }.background(Color.blue)
                    }
                    
                    Text(errorMessage)
                        .foregroundColor(Color.red)
                        .font(Font.system(size: 18).bold())
                    
                    Text(successMessage)
                        .foregroundColor(Color.blue)
                        .font(Font.system(size: 18).bold())
                    
                }.padding()
                
            }
            .navigationTitle(isLoginMode ? "Login" : "Create Account")
            .background(Color(.init(white: 0, alpha: 0.15)).ignoresSafeArea())
        }
        //for ipad..
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $showImagePicker, onDismiss: nil) {
            ImagePicker(image: $image)
        }
    }
    
    private func loginOrCreateAccount() {
        if isLoginMode {
            if (password.count < 4 || email.count < 4 ) {
                print("input email and password more than 4 characters")
                self.errorMessage = "input email and password more than 4 characters"
                return
            }
            
            login()
            
        } else {
            //check string length of mail and password
            if (password.count < 4 || email.count < 4 || passwordCheck.count < 4) {
                print("input email and password more than 4 characters")
                self.errorMessage = "input email and password more than 4 characters"
                return
            }
            
            //passsword check
            if (password != passwordCheck) {
                print("password dose not correspond to passwordCheck")
                self.errorMessage = "password dose not correspond to passwordCheck"
                return
            }
            
            
            if (self.image == nil) {
                self.errorMessage = "please pick a image"
                return
            }
            createNewAccount()
            
        }
    }
    
    private func login(){
        
        Auth.auth().signIn(withEmail: email, password: password) {
            result, error in
            if let error = error {
                print("Failed to login user:", error)
                self.successMessage = ""
                self.errorMessage = "Failed to login user: \(error)"
                return
            }
            
            print("successfully logged in as user: \(result?.user.uid ?? "")")
            self.errorMessage = ""
            self.successMessage = "successfully logged in as user: \(result?.user.uid ?? "")"
            
            self.didloginProcess()
            
        }
        
    }
    
    private func createNewAccount(){
        
        Auth.auth().createUser(withEmail: email, password: password) {
            result, error in
            if let error = error {
                print("Fialed to create user:", error)
                self.successMessage = ""
                self.errorMessage = "Fialed to create user: \(error)"
                return
            }
            
            print("successfully created user: \(result?.user.uid ?? "")")
            
            self.errorMessage = ""
            self.successMessage = "successfully created user: \(result?.user.uid ?? "")"
            
            imageToStorage()
            
            
        }
        
    }
    
    private func imageToStorage() {
        //        let imageUrl = UUID().uuidString
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Storage.storage().reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else { return }
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                self.errorMessage = "Failed to push image to Storage: \(error)"
                self.successMessage = ""
                return
            }
            ref.downloadURL { url, error in
                if let error = error {
                    self.successMessage = "Failed to get downloadUrl: \(error)"
                    return
                }
                
                self.successMessage = "stored image with url: \(url?.absoluteString ?? "")"
                guard let url = url else { return }
                storeUserInformation(imageProfileUrl: url)
                
            }
        }
        
    }
    
    private func storeUserInformation(imageProfileUrl: URL) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userData = [
            "email": self.email,
            "uid": uid,
            "profileImageUrl": imageProfileUrl.absoluteString]
        Firestore.firestore().collection("users").document(uid).setData(userData) { error in
            if let error = error {
                print(error)
                self.errorMessage = "\(error)"
                return
            }
            
            print("stored new user data")
            
            self.cleanTextfileds()
            self.isLoginMode = true
            
            self.errorMessage = ""
            self.successMessage = "stored user data"
            
            
        }
        
    }
    
    private func cleanTextfileds(){
        self.email = ""
        self.password = ""
        self.passwordCheck = ""
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(didloginProcess: {
            
        })
    }
}
