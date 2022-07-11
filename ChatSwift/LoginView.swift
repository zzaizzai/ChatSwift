//
//  ContentView.swift
//  ChatSwift
//
//  Created by 小暮準才 on 2022/07/11.
//

import SwiftUI

struct LoginView: View {
    
    @State var isLoginMode = true
    @State var email = ""
    @State var password = ""
    
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
                        Image(systemName: "person.fill")
                            .font(.system(size: 64))
                            .padding()
                    }
                    
                    Group {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        TextField("Password", text: $password)
                            .autocapitalization(.none)
                    }.padding(12)
                        .background(Color.white)
                    
                    
                    Button{
                        handleAction()
                        
                    } label: {
                        HStack{
                            Spacer()
                            Text("Create Account")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                            Spacer()
                        }.background(Color.blue)
                    }
                    
                }.padding()
                
            }
            .navigationTitle(isLoginMode ? "Login" : "Create Account")
            .background(Color(.init(white: 0, alpha: 0.15)).ignoresSafeArea())
        }
    }
    
    private func handleAction() {
        if isLoginMode {
            print("login")
        } else {
            print("register")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
