//
//  LoginView.swift
//  ChatApp_Fianl
//
//  Created by 村瀬賢司 on 2023/03/19.
//

import Foundation
import SwiftUI


// サーバへ送信するログイン情報
struct LoginInfo: Codable {
    //var RegistrationDate:String
    var LoginID: String
    var Password: String
}

class PostLoginInfo: ObservableObject {
    @Published var loginInfo = LoginInfo(LoginID: "", Password: "")
    @Published var resBody = ""
    @Published var changeLoginViewFlag: Bool
    @Published var loginCheck: Bool
    
    init() {
        changeLoginViewFlag = true
        loginCheck = false
    }
    
    // ログイン情報をサーバへ送信する処理
    func post_LoginInfo() {
        // URLの生成
        guard let url = URL(string: "http://\(srv_IPaddress):3000/login") else {
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
        var loginData_json = Dictionary<String, Any>()
        loginData_json["LoginID"] = loginInfo.LoginID
        loginData_json["Password"] = loginInfo.Password
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: loginData_json, options: [])
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
                //statusCode = response.statusCode
                // HTTPのBodyを取得
                // バイナリーをString型へ変換
                self.resBody = String(data: data, encoding: .utf8)!
                // String型をData型に変換
                var resData: Data = self.resBody.data(using: String.Encoding.utf8)!
                do {
                    // Data型からDictionary型に変換
                    var jsonData = try JSONSerialization.jsonObject(with: resData) as! Dictionary<String, String>
                    // ログイン成功時の処理
                    if jsonData["LoginCheck"]! == "Login successed!" {
                        // Home画面に戻るためのフラグ変数
                        self.changeLoginViewFlag = false
                        // Home画面で表示する画面の変更
                        self.loginCheck = true
                        // ログイン成功時のresponseBodyを返却
                        self.resBody = jsonData["LoginCheck"]!
                    }
                    print(jsonData["LoginCheck"]!)
                } catch {
                    print(error)
                }
                
            }
        }.resume()
        
    }
    
}


struct LoginView: View {
    @Binding var changeLoginViewFlag: Bool
    @Binding var loginCheck: Bool
    //@Binding var loginID_Share: String
    var resBody = ""
    //@State private var statusCode = 0
    @FocusState var isInputActive: Bool
    //@State private var loginInfo = LoginInfo(LoginID: "kenji", Password: "toire")
    @ObservedObject var postLoginInfo = PostLoginInfo()
    
    
    var body: some View {
        VStack {
            Text("ログインID")
                .font(.title)
                .padding()
            //Text("\(loginInfo.LoginID)")
                //.font(.title2)
            TextField("ログインID", text: $postLoginInfo.loginInfo.LoginID)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 200)
            Text("パスワード")
                .font(.title)
                .padding()
            //Text("\(loginInfo.Password)")
                //.font(.title2)
                //.padding()
            TextField("パスワード", text: $postLoginInfo.loginInfo.Password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 200)
            
            // 送信ボタン
            Button(action: {
                // ログイン情報をサーバへ送信する処理
                postLoginInfo.post_LoginInfo()
                // 成功時の画面遷移用フラグの再設定
                if (postLoginInfo.resBody == "Login successed!") {
                    changeLoginViewFlag = postLoginInfo.changeLoginViewFlag
                    loginCheck = postLoginInfo.loginCheck
                    // ログインIDのデータを他のViewにも共有する
                    loginID_Share = postLoginInfo.loginInfo.LoginID
                }
            }) {
                Text("Send LoginInfo to Server of EC2!")
                    .font(.body)
                    .frame(width: 300, height: 50, alignment: .center)
                    .background(Color.orange)
                    .foregroundColor(Color.blue)
            }
            .padding()
            
            Text("\(postLoginInfo.resBody)")
                .padding()
            
            // 新規ユーザ登録サイトへボタン
            Button("新規ユーザ登録サイトへ移動"){
                if let url = URL(string: "http://\(srv_IPaddress):3000/createUser") {
                    UIApplication.shared.open(url)
                }
            }
            .padding()
            
            // Home画面へ戻るボタン
            Button("Homeへ戻る") {
                changeLoginViewFlag = false
            }
        }
    }
    /*
    // ログイン情報をサーバへ送信する処理
    func Send_LoginInfo_ToLoginServer() {
        // URLの生成
        guard let url = URL(string: "http://\(srv_IPaddress):3000/login") else {
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
        var loginData_json = Dictionary<String, Any>()
        loginData_json["LoginID"] = loginInfo.LoginID
        loginData_json["Password"] = loginInfo.Password
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: loginData_json, options: [])
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
                //statusCode = response.statusCode
                // HTTPのBodyを取得
                // バイナリーをString型へ変換
                resBody = String(data: data, encoding: .utf8)!
                // String型をData型に変換
                var resData: Data = resBody.data(using: String.Encoding.utf8)!
                do {
                    // Data型からDictionary型に変換
                    var jsonData = try JSONSerialization.jsonObject(with: resData) as! Dictionary<String, String>
                    // ログイン成功時の処理
                    if jsonData["LoginCheck"]! == "Login successed!" {
                        // Home画面に戻るためのフラグ変数
                        changeLoginViewFlag = false
                        // Home画面で表示する画面の変更
                        loginCheck = true
                    }
                    print(jsonData["LoginCheck"]!)
                } catch {
                    print(error)
                }
                
            }
        }.resume()
        
    }
     */
}



