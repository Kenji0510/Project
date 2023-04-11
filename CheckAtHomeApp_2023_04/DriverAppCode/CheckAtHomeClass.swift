//
//  CheckAtHomeClass.swift
//  SwiftUI_DriverApp1
//
//  Created by 村瀬賢司 on 2023/04/07.
//

import Foundation


// 各利用者の在宅チェックリストの構造体
struct CheckAtHomeList {
    var userName: String
    var isPeripheral: Bool
    var checkTime: String
}

struct CheckList: Codable {
    let userName: String
    let Address: String
    let isPeripheral: String
}

// サーバのIPアドレス
let srv_IPaddress = "219.122.158.86" // "219.122.158.86"


class checkAtHome: ObservableObject {
    @Published var userName: String
    @Published var isPeripheral: Bool
    @Published var checkAtHomeList: [CheckAtHomeList] = []
    
    @Published var checkList: [CheckList] = []
    
    
    init() {
        userName = ""
        isPeripheral = false
        
        checkList.append(CheckList(userName: "", Address: "", isPeripheral: ""))
        
        checkAtHomeList.append(CheckAtHomeList(userName: "kenji1", isPeripheral: false, checkTime: "2023-04-07 00:00:00"))
        checkAtHomeList.append(CheckAtHomeList(userName: "kenji2", isPeripheral: false, checkTime: "2023-04-07 00:00:00"))
        checkAtHomeList.append(CheckAtHomeList(userName: "kenji3", isPeripheral: false, checkTime: "2023-04-07 00:00:00"))
        checkAtHomeList.append(CheckAtHomeList(userName: "kenji4", isPeripheral: false, checkTime: "2023-04-07 00:00:00"))
        checkAtHomeList.append(CheckAtHomeList(userName: "toire1", isPeripheral: true, checkTime: "2023-04-07 00:00:01"))
        checkAtHomeList.append(CheckAtHomeList(userName: "toire2", isPeripheral: true, checkTime: "2023-04-07 00:00:01"))
        checkAtHomeList.append(CheckAtHomeList(userName: "toire3", isPeripheral: true, checkTime: "2023-04-07 00:00:01"))
    }
    
    
    // サーバから在宅チェックデータを取得する関数
    func getCheckAtHome() {
        // URLの生成
        guard let url = URL(string: "http://\(srv_IPaddress):3000/getCheckAtHome") else {
            // URLが無効なケースの処理
            print("URL is invalid!")
            return
        }
        
        // URLリクエスト（POST）
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // とりあえず何かのデータをサーバへ送信
        var loginID_JSON = Dictionary<String, Any>()
        loginID_JSON["LoginID"] = "Hello!"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: loginID_JSON, options: [])
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
                
                // HTTPのBodyに格納されているJSONデータをDictionary型に変換
                do {
                    // 配列形式でJSONデータを受信
                    let list: [CheckList] = try JSONDecoder().decode([CheckList].self, from: data)
                    self.checkList = list
                } catch {
                    print(error)
                }
 
                /*
                 DispatchQueue.main.async
                // システム全体で共有される並列のキューで同期的に実行
                DispatchQueue.global().sync{
                    
                }
                 */
                
            }
        }.resume()
    }
    
}
