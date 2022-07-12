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
                            print("photo")
                            
                        } label: {
                            Image(systemName: "photo")
                                .font(.system(size: 64))
                                .padding()
                            
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
                    
                }.padding()
                
            }
            .navigationTitle(isLoginMode ? "Login" : "Create Account")
            .background(Color(.init(white: 0, alpha: 0.15)).ignoresSafeArea())
        }
        //for ipad..
        .navigationViewStyle(StackNavigationViewStyle())
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
        errorMessage = "login"
        
    }
    
    private func createNewAccount(){
        print("register")
        cleanTextfileds()
        errorMessage = "successfully account created"
        isLoginMode = true
        
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
