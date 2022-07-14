//
//  MainMessageView.swift
//  ChatSwift
//
//  Created by 小暮準才 on 2022/07/14.
//

import SwiftUI

struct MainMessageView: View {
    var body: some View {
        NavigationView{
            ScrollView{
                ForEach(0..<10, id: \.self){ num in
                    HStack{
                        Text("user profile image")
                        VStack{
                            Text("username")
                            Text("message")
                        }
                        Text("date")
                        
                    }
                    Divider()
                }
            }
            .navigationTitle("main messages")
        }
    }
}

struct MainMessageView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessageView()
    }
}
