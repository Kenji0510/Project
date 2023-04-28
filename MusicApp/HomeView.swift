//
//  HomeView.swift
//  MusicApp
//
//  Created by 村瀬賢司 on 2023/04/14.
//

import Foundation
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var musicControl: MusicControl
    
    var body: some View {
        VStack {
            List {
                NavigationLink(destination: DownloadMusicListView()) {
                    Text("音楽データをダウンロードする")
                }.padding()
                NavigationLink(destination: MusicListView()) {
                    Text("音楽を再生する")
                }.padding()
                NavigationLink(destination: ConvertToMP3_View()) {
                    Text("YouTubeのURLをMP3へ変換する")
                }.padding()
            }
        }
        .navigationTitle("ホーム画面")
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(MusicControl()).environmentObject(DownloadMusicData())
    }
}
