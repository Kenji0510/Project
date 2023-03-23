//
//  ContentView.swift
//  ChatApp_Fianl
//
//  Created by 村瀬賢司 on 2023/03/19.
//

import SwiftUI


// ログインサーバ(EC2)のIPアドレス
let srv_IPaddress = "35.78.93.168"



struct ContentView: View {
    @State var changeLoginViewFlag: Bool = false
    @State var loginCheck: Bool = false
    @State var changeChatViewFlag: Bool = false
    //@State var loginID_Share = ""
    
    var body: some View {
        NavigationView {
            // ログイン前の画面
            if !loginCheck {
                VStack {
                    NavigationLink(destination: LoginView(changeLoginViewFlag: $changeLoginViewFlag, loginCheck: $loginCheck), isActive: $changeLoginViewFlag) {
                        EmptyView()
                    }
                    .navigationTitle("Home")
                    // ログイン画面へ移るためのボタン
                    Button {
                        changeLoginViewFlag = true
                    } label: {
                        Text("ログイン画面へ")
                    }
                }
            } else {
                // 以下、チャット画面
                NavigationLink(destination: ChatView(), isActive: $changeChatViewFlag) {
                    //EmptyView()
                    // ChatViewへ画面遷移するためのボタン
                    Button {
                        changeChatViewFlag = true
                    } label: {
                        Text("チャット画面へ")
                    }
                }
                .navigationTitle("Home2")

                // ログイン成功後の画面
                //Text("Login successed!")
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
