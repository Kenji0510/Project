//
//  SendURLToServer.swift
//  MusicApp
//
//  Created by 村瀬賢司 on 2023/04/20.
//

import Foundation
import SwiftUI


struct ResponseData: Codable {
    let resMessage: String
}

class SendURLToServer: ObservableObject {
    @Published var responseData: String
    
    
    init() {
        responseData = ""
    }
    
    // 入力されたURLの有効性を確認
    func validationUrl(youtubeURL: String) -> Bool {
        guard let encurl = youtubeURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) else {
            return false
        }
        if let url = NSURL(string: encurl) {
            return UIApplication.shared.canOpenURL(url as URL)
        }
        return false
    }
    
    // サーバへ送信する入力データを検査する
    func checkInsertStr(youtubeURL: String, saveMusicName: String) -> (checkMusicNameResult: String, checkUrlResult: Bool) {
        var checkMusicNameResult: String = ""
        var checkURL: String = ""
        
        // 保存する音楽ファイル名に「スペース」があるケース
        if (saveMusicName.contains(" ")) {
            checkMusicNameResult = "included space in saveMusicName"
        }
        // 保存する音楽ファイル名の末尾に「.mp3」がないケース
        if (!saveMusicName.hasSuffix(".mp3")) {
            checkMusicNameResult = "Not included \".mp3\" in saveMusicName"
        }
        
        // 入力されたURLの有効性を確認
        let checkUrlResult: Bool = validationUrl(youtubeURL: youtubeURL)
        
        return (checkMusicNameResult, checkUrlResult)
    }
    
    // サーバへ動画URLと保存ファイル名を送信
    func sendConvertMusicInfo(youtubeURL: String, saveMusicName: String) -> String {
        var errorMessage = ""
        // サーバへ送信する入力データを検査する
        let checkResult = checkInsertStr(youtubeURL: youtubeURL, saveMusicName: saveMusicName)
        
        if (checkResult.checkMusicNameResult == "included space in saveMusicName") {
            errorMessage += "included space in saveMusicName \n"
        } else if (checkResult.checkMusicNameResult == "Not included \".mp3\" in saveMusicName"){
            errorMessage += "Not included \".mp3\" in saveMusicName \n"
        } else if (checkResult.checkUrlResult == false) {
            errorMessage += "URL is invalid! \n"
        } else {
            errorMessage = "No error"
        }
        // エラーがあればここで関数から離脱
        if (errorMessage != "No error") {
            return errorMessage
        }
        
        let url = URL(string: "http://\(srvIPaddr):3000/requestConvertToMP3")!
        
        // URLリクエスト(POST)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // サーバに変換したい動画の情報を送信
        var convertMusicInfo = Dictionary<String, Any>()
        convertMusicInfo["youtubeURL"] = youtubeURL
        convertMusicInfo["saveMusicName"] = saveMusicName
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: convertMusicInfo, options: [])
        } catch {
            print(error.localizedDescription)
        }
        
        // サブスレッドで送信処理を実行(UIのメインスレッド実行の邪魔をしないように！！)
        DispatchQueue.global().async {
            URLSession.shared.dataTask(with: request) {
                (data, res, error) in
                if error == nil, let data = data, let res = res as? HTTPURLResponse {
                    //HTTPヘッダの取得
                    print("Content-Type: \(res.allHeaderFields["Content-Type"] ?? "")")
                    // HTTPステータスコード
                    print("statusCode: \(res.statusCode)")
                    
                    // HTTPのBodyに格納されているJSONデータをDictionary型に変換
                    do {
                        // JSONデータを変数に格納
                        let response: ResponseData = try JSONDecoder().decode(ResponseData.self, from: data)
                        self.responseData = response.resMessage
                        print(self.responseData)
                    } catch {
                        print(error)
                    }
                }
            }
            .resume()
        }
        
        return errorMessage
    }
    
    
}
