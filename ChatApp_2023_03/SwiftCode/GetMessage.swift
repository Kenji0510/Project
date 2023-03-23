//
//  GetMessage.swift
//  ChatApp_Fianl
//
//  Created by 村瀬賢司 on 2023/03/20.
//

import Foundation



class GetMessage: ObservableObject {
    @Published var loginID: String = "murase"
    @Published var messageData: String = "toire"
    private var timer: Timer
    
    
    init() {
        timer = Timer()
        timerStart()
    }
    
    // 5秒経過するたびにサーバからメッセージ取得する関数のトリガー
    func timerStart() {
        guard !timer.isValid else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) {
            _ in
            self.getMessage()
        }
    }
    
    // EC2のメッセージサーバからChatメッセージを受信する処理
    func getMessage() {
        // URLの生成
        guard let url = URL(string: "http://\(srv_IPaddress):3000/getMessage") else {
            // URLが無効なケースの処理
            print("URL is invalid!")
            return
        }
        
        // URLリクエスト（POST）
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // メッセージサーバに指定したLoginIDを送信(POST)するデータをBodyとして設定
        var loginID_json = Dictionary<String, Any>()
        loginID_json["LoginID"] = self.loginID
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: loginID_json, options: [])
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
                // システム全体で共有される並列のキューで同期的に実行
                DispatchQueue.global().sync{
                    // JSON形式のデータをPerson型の構造体変数に合う形で代入（変換）
                    let MsFromJSON = try! JSONDecoder().decode(MessageInfo.self, from: data)
                    self.loginID = MsFromJSON.LoginID
                    self.messageData = MsFromJSON.MessageData
                }
                
            }
        }.resume()
    }
}
