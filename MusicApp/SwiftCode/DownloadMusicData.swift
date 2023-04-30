//
//  DownloadMusicData.swift
//  MusicApp
//
//  Created by 村瀬賢司 on 2023/04/15.
//

import Foundation


struct MusicInfoList: Codable {
    var MusicName: String
    var RegistrationDate: String
}


// プライベートIP
var srvIPaddr = "192.168.0.100"
// グローバルIP
//var srvIPaddr = "219.122.158.86"


class DownloadMusicData: ObservableObject {
    @Published var musicInfoList: [MusicInfoList]
    
    
    init() {
        
        musicInfoList = []
    }
    
    // サーバから音楽データのリスト情報を取得
    func getMusicListInfo() {
        // URLの生成
        guard let url = URL(string: "http://\(srvIPaddr):3000/getMusicInfo") else {
            // URLが無効なケース
            print("URL is invalid!")
            return
        }
        // URLリクエスト（POST）
        let request = URLRequest(url: url)
        
        // URLにアクセス
        URLSession.shared.dataTask(with: request) {
            data, response, error in
            if error == nil, let data = data, let response = response as? HTTPURLResponse {
                //HTTPヘッダの取得
                print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
                // HTTPステータスコード
                print("statusCode: \(response.statusCode)")
                // HTTPのBodyを取得
                // メインスレッドの並列のキューで非同期的に実行
                DispatchQueue.main.async {                    // MusicInfoListの配列形式でJSONデータをDictionary型で格納
                    do {
                        let list: [MusicInfoList] = try JSONDecoder().decode([MusicInfoList].self, from: data)
                        self.musicInfoList = list
                        // 「"」を音楽ファイル名から削除
                        for i in 0..<self.musicInfoList.count {
                            self.musicInfoList[i].MusicName.removeAll(where: { $0 == "\""})
                        }
                        
                        print(self.musicInfoList)
                    } catch {
                        print(error)
                    }
                }
                
            }
        }.resume()
        
    }
    
    // サーバから指定した音楽データをダウンロード
    func downloadMusicData(fileName: String) {
        let url = URL(string: "http://\(srvIPaddr):3000/music")!
        
        // URLリクエスト(POST)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // サーバにアプリで指定した音楽ファイル名を送信
        var selectMusicName = Dictionary<String, Any>()
        selectMusicName["selectMusicName"] = fileName
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: selectMusicName, options: [])
        } catch {
            print(error.localizedDescription)
        }
        
        // サブスレッドでダウンロード処理を実行(UIのメインスレッド実行の邪魔をしないように！！)
        DispatchQueue.global().async {
            let downloadTask = URLSession.shared.dataTask(with: request) {
                (data, res, error) in
                self.saveMusicData(data: data!, fileName: fileName)
            }
            downloadTask.resume()
        }
    }
    
    // ダウンロードした音楽データをDocumentsファイルに保存する
    func saveMusicData(data: Data, fileName: String) {
        // DocumentsフォルダURL取得
        guard let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("フォルダURL取得エラー")
        }
        
        // 対象のファイルURL取得
        let fileURL = docURL.appendingPathComponent(fileName)
        
        // 音楽データを書き込み
        do {
            try data.write(to: fileURL)
        } catch {
            print("Error: \(error)")
        }
    }
    
}
