//
//  ChatView.swift
//  ChatApp_Fianl
//
//  Created by 村瀬賢司 on 2023/03/20.
//

import Foundation
import SwiftUI


// サーバへ送信する and サーバから受信するメッセージ情報
struct MessageInfo: Codable {
    var LoginID: String
    var MessageData: String
}

var loginID_Share: String = ""

struct ChatView: View {
    //@Binding var loginID_Share: String
    @ObservedObject var getMessageData = GetMessage()
    @ObservedObject var postMessageData = PostMessage()
    
    
    var body: some View {
        VStack {
            // 受信メッセージ表示
            Text("受信メッセージ")
                .font(.title)
                .padding()
            Text("\(getMessageData.loginID) : \(getMessageData.messageData)")
                .font(.body)
                .padding()
            
            // 送信メッセージ表示
            Text("送信メッセージ")
                .font(.title)
            Text("\(postMessageData.loginID) : \(postMessageData.messageData)")
                .font(.body)
                .padding()
            TextField("メッセージ", text: $postMessageData.messageData)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 200)
                
            // 送信ボタン
            Button("送信する"){
                postMessageData.postMessage()
            }
            .font(.body)
            .frame(width: 150, height: 35, alignment: .center)
            .background(Color.orange)
            .foregroundColor(Color.blue)
             
            
        }
        .padding()
    }
}
