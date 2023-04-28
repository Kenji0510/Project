//
//  ContentView.swift
//  MusicApp
//
//  Created by 村瀬賢司 on 2023/04/14.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            NavigationView {
                HomeView()
            }.navigationViewStyle(StackNavigationViewStyle())   // Ipadの表示を切り替える
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(MusicControl()).environmentObject(DownloadMusicData())
    }
}
