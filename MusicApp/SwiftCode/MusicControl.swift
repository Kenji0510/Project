//
//  MusicControl.swift
//  MusicApp
//
//  Created by 村瀬賢司 on 2023/04/14.
//

import Foundation
import AVFoundation


class MusicControl: ObservableObject {
    @Published var audioPlayer: AVAudioPlayer
    //@Published var sliderTime: Double
    var docURL: URL
    
    var text:String
    
    @Published var musicFiles: [String]
    
    
    init() {
        self.audioPlayer = AVAudioPlayer()
        docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        musicFiles = []
        
        text = "Hello!"
        self.writeFile(fileName: "text.txt")
        
        //self.sliderTime = 0
    }
    
    func writeFile(fileName: String) {
        // Documentsディレクトリまでのパスを生成
        guard let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("URL取得失敗")
        }
        // ファイル名を含めたフルパスを生成
        let fullURL = docURL.appendingPathComponent(fileName)
        
        do {
            try text.write(to: fullURL, atomically: true, encoding: .utf8)
        } catch {
            print("書き込み失敗")
        }
    }
    
    // Documentディレクトリのファイル郡のファイル名取得
    func getDocumentURL() {
        do {
            let contentUrls = try FileManager.default.contentsOfDirectory(at: docURL, includingPropertiesForKeys: nil)
            musicFiles = contentUrls.map{$0.lastPathComponent}
            // "text.txt"は音楽リストから省く
            //musicFiles.removeAll(where: {$0 == "text.txt"})
            // 隠しファイルの".Trash"も省く
            //musicFiles.removeAll(where: {$0 == ".Trash"})
            
            var count: Int = 0
            // 拡張子がmp3（mp3ファイル）以外のファイルは削除
            for i in 0..<self.musicFiles.count {
                // Out of rangeを防ぐ
                if (i == musicFiles.count - count) {
                    break
                }
                if (!(self.musicFiles[i].contains(".mp3") || self.musicFiles[i].contains(".aiff") || self.musicFiles[i].contains(".m4a") || self.musicFiles[i].contains(".wav"))) {
                    self.musicFiles.remove(at: i)
                    count = count + 1
                }
            }
            
        } catch {
            print("フォルダが空です")
        }
    }
    
    // 音楽ファイルのURLを取得
    func setURL(fileName: String) -> URL {
        return docURL.appendingPathComponent(fileName)
    }
    
    // 音楽再生準備
    func setAudioData(fileName: String) {
        // 音楽ファイルのURLを取得
        let audioFileUrl: URL = setURL(fileName: fileName)
        print(audioFileUrl)
        
        do {
            //audioPlayer = try! AVAudioPlayer(contentsOf: audioFileUrl, fileTypeHint: AVFileType.mp3.rawValue)
            audioPlayer = try! AVAudioPlayer(contentsOf: audioFileUrl)
            audioPlayer.prepareToPlay()
        } catch {
            print(error)
        }
    }
    
    // 音楽再生開始
    func audioPlay() {
        //audioPlayer.volume = 0.25
        audioPlayer.play()
    }
    
    // 音楽再生一時停止
    func audioPause() {
        audioPlayer.pause()
        print(audioPlayer.currentTime)
    }
    
    // 音楽再生停止
    func audioStop() {
        audioPlayer.stop()
        audioPlayer.currentTime = 0.0
    }
    
    // 音楽再生ループ
    func audioLoop() {
        DispatchQueue.main.async {
            self.audioPlayer.numberOfLoops = -1
        }
    }
    
    // 音楽再生ループ解除
    func audioLoopRelease() {
        DispatchQueue.main.async {
            self.audioPlayer.numberOfLoops = 0
        }
    }
    
    // シークバーによる音声再生位置変更
    func changeMusicTime(musicTime: Double) {
        audioPlayer.pause()
        DispatchQueue.main.async {
            self.audioPlayer.currentTime = musicTime
        }
        audioPlayer.play()
    }
    
    // シークバーによる再生値変更を取得
    func getMusicCurrentTime() -> Double {
        return audioPlayer.currentTime
    }
}
