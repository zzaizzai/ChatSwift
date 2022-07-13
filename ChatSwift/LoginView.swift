//
//  ContentView.swift
//  ChatSwift
//
//  Created by 小暮準才 on 2022/07/11.
//

import SwiftUI
import Firebase

struct LoginView: View {
    
    @State var isLoginMode = true
    @State var email = ""
    @State var password = ""
    @State var passwordCheck = ""
    @State var errorMessage = ""
    @State var successMessage = ""
    @State var showImagePicker = false
    @State var image: UIImage?
    
    
    var body: some View {
        NavigationView{
            ScrollView{
                
                VStack{
                    
                    Picker(selection: $isLoginMode, label: Text("good")) {
                        Text("login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                    }.pickerStyle(SegmentedPickerStyle())
                        .padding()
                    
                    if !isLoginMode {
                        Button{
                            showImagePicker.toggle()
                            
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
                            Text("Create Account")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
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
                errorMessage = "input email and password more than 4 characters"
                return
            }
            
            login()
            
        } else {
            //check string length of mail and password
            if (password.count < 4 || email.count < 4 || passwordCheck.count < 4) {
                print("input email and password more than 4 characters")
                errorMessage = "input email and password more than 4 characters"
                return
            }
            
            //passsword check
            if (password != passwordCheck) {
                print("password dose not correspond to passwordCheck")
                errorMessage = "password dose not correspond to passwordCheck"
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
                successMessage = ""
                errorMessage = "Failed to login user: \(error)"
                return
            }
            
            print("successfully logged in as user: \(result?.user.uid ?? "")")
            errorMessage = ""
            successMessage = "successfully logged in as user: \(result?.user.uid ?? "")"
            
        }
        
    }
    
    private func createNewAccount(){

        Auth.auth().createUser(withEmail: email, password: password) {
            result, error in
            if let error = error {
                print("Fialed to create user:", error)
                successMessage = ""
                errorMessage = "Fialed to create user: \(error)"
                return
            }
            
            print("successfully created user: \(result?.user.uid ?? "")")
            
            errorMessage = ""
            successMessage = "successfully created user: \(result?.user.uid ?? "")"
            
            print("register")
            cleanTextfileds()
            isLoginMode = true
        }
        
    }
    
    private func cleanTextfileds(){
        email = ""
        password = ""
        passwordCheck = ""
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
