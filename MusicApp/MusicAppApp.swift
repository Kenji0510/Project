//
//  MusicAppApp.swift
//  MusicApp
//
//  Created by 村瀬賢司 on 2023/04/14.
//

import SwiftUI

@main
struct MusicAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(MusicControl()).environmentObject(DownloadMusicData())
        }
    }
}
