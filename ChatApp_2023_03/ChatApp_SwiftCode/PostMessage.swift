//
//  PostMessage.swift
//  ChatApp_Fianl
//
//  Created by 村瀬賢司 on 2023/03/20.
//

import Foundation



class PostMessage: ObservableObject {
    @Published var loginID: String = loginID_Share
    @Published var messageData: String = ""
    
    /*
    init(loginID_share: String) {
        self.loginID = loginID_share
    }
     */
    
    // ログイン情報をサーバへ送信する処理
    func postMessage() {
        // URLの生成
        guard let url = URL(string: "http://\(srv_IPaddress):3000/postMessage") else {
            // URLが無効なケースの処理
            print("URL is invalid!")
            return
        }
        
        // URLリクエスト（POST）
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // ログインサーバログイン情報を送信(POST)するデータをBodyとして設定
        var MessageData_json = Dictionary<String, Any>()
        MessageData_json["LoginID"] = self.loginID
        MessageData_json["MessageData"] = self.messageData
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: MessageData_json, options: [])
        } catch {
            print(error.localizedDescription)
        }
        
        // URLにアクセス
        URLSession.shared.dataTask(with: request) {
            data, response, error in
            if error == nil, let data = data, let response = response as? HTTPURLResponse {
                //HTTPヘッダの取得
                print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
                // HTTPステータスコード
                print("statusCode: \(response.statusCode)")
                // HTTPのBodyを取得
                //resBody = String(data: data, encoding: .utf8)!
                // JSON形式のデータをPerson型の構造体変数に合う形で代入（変換）
                //var MsFromJSON = try! JSONDecoder().decode(MessageInfo.self, from: data)
                //self.loginID = MsFromJSON.loginID
                //self.messageData = MsFromJSON.messageData
            }
        }.resume()
    }
}
