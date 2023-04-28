//
//  AppDelegate.swift
//  MusicApp
//
//  Created by 村瀬賢司 on 2023/04/28.
//

import Foundation
import UIKit
import AVFoundation


class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // AVAudioSessionCategory設定
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default)
        } catch {
            // エラー
            fatalError("Category設定失敗")
        }
        
        // session初期化
        do {
            try session.setActive(true)
        }catch {
            fatalError("Session有効失敗")
        }
        
        return true
    }
}
