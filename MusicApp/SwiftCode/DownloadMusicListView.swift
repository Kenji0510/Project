//
//  DownloadMusicListView.swift
//  MusicApp
//
//  Created by 村瀬賢司 on 2023/04/14.
//

import Foundation
import SwiftUI


struct DownloadMusicListView: View {
    @EnvironmentObject var downloadMusicData: DownloadMusicData
    
    var body: some View {
        VStack {
            // ダウンロード可能な音楽データリスト
            List {
                if (downloadMusicData.musicInfoList.count != 0) {
                    Section {
                        ForEach(0..<downloadMusicData.musicInfoList.count, id: \.self) {
                            num in
                            // 指定した音楽のデータダウンロード画面
                            NavigationLink(destination: DownloadMusicDataView(selectNum: num)) {
                                Text("音楽名: \(downloadMusicData.musicInfoList[num].MusicName), 登録日: \(downloadMusicData.musicInfoList[num].RegistrationDate)")
                            }
                        }
                    } header: {
                        Text("ダウンロード可能な音楽データリスト")
                    }
                }
            }
            
            // サーバから音楽データのリスト情報を取得する
            Button("音楽データのリスト情報を更新する") {
                downloadMusicData.getMusicListInfo()
            }
        }
        .navigationTitle("音楽データダウンロードリスト画面")
    }
    
    // 指定した音楽のデータダウンロード画面
    struct DownloadMusicDataView: View {
        @EnvironmentObject var downloadMusicData: DownloadMusicData
        var selectNum: Int
        
        var body: some View {
            VStack {
                Text("曲名: \(downloadMusicData.musicInfoList[selectNum].MusicName)").padding()
                Text("曲名: \(downloadMusicData.musicInfoList[selectNum].RegistrationDate)").padding()
                
                Button("ダウンロードする") {
                    downloadMusicData.downloadMusicData(fileName: downloadMusicData.musicInfoList[selectNum].MusicName)
                }
            }
        }
    }
    
    
}

struct DownloadMusicListView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadMusicListView().environmentObject(MusicControl()).environmentObject(DownloadMusicData())
    }
}
