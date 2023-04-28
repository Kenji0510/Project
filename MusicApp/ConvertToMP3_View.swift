//
//  ConvertToMP3_View.swift
//  MusicApp
//
//  Created by 村瀬賢司 on 2023/04/20.
//

import Foundation
import SwiftUI



struct ConvertToMP3_View: View {
    @State var youtubeURL = ""
    @State var saveMusicName = ""
    @State var checkResult = ""
    var sendURLProcess = SendURLToServer()
    
    
    var body: some View {
        VStack {
            Text("MP3へ変換したいYouTubeの動画URLを入力")
                .padding()
            // YouTubeの動画URLを入力
            TextField("変換したいYouTubeのURL", text: $youtubeURL)
                .textFieldStyle(.roundedBorder)
                .padding()
            Text("変換後の音楽ファイル名を入力")
                .padding()
            // 変換後の音楽ファイル名を入力
            TextField("変換後の音楽ファイル名", text: $saveMusicName)
                .textFieldStyle(.roundedBorder)
                .padding()
            // サーバへ入力された動画URLを送信するボタン
            Button("サーバへ送信"){
                checkResult = sendURLProcess.sendConvertMusicInfo(youtubeURL: youtubeURL, saveMusicName: saveMusicName)
            }
            .padding()
            
            // 入力チェックの確認結果
            Text("\(checkResult)").lineLimit(nil).padding()
            
        }
    }
}


struct ConvertToMP3_View_Previews: PreviewProvider {
    static var previews: some View {
        ConvertToMP3_View().environmentObject(MusicControl()).environmentObject(DownloadMusicData())
    }
}
