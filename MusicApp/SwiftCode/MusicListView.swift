//
//  MusicListView.swift
//  MusicApp
//
//  Created by 村瀬賢司 on 2023/04/14.
//

import Foundation
import SwiftUI


struct MusicListView: View {
    @EnvironmentObject var musicControl: MusicControl
    
    var body: some View {
        VStack {
            // 音楽ファイル名のリスト
            List {
                ForEach(0..<musicControl.musicFiles.count, id:\.self) {
                    num in
                    NavigationLink(destination: MusicPlayView(selectNum: num)) {
                        Text(musicControl.musicFiles[num])
                    }
                    /*
                    .simultaneousGesture(TapGesture().onEnded {
                        musicControl.setAudioData(fileName: musicControl.musicFiles[num])
                    })*/
                }
            }
            Button("音楽ファイル名取得") {
                musicControl.getDocumentURL()
            }.padding()
        }
        .navigationTitle("ダウンロード済み音楽リスト")
    }
    
    // 選択した音楽の再生画面
    struct MusicPlayView: View {
        @EnvironmentObject var musicControl: MusicControl
        @State var musicTime: Double = 0
        @State var isChangedSlider: Bool = false
        @State var firstPlay: Bool = false
        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        var selectNum: Int
        var timeModel = TimeModeling()
        
        
        var body: some View {
            VStack {
                Text("曲名: \(musicControl.musicFiles[selectNum])")
                    .padding()
                
                // 音楽の再生位置変更(タイマーよりSliderの値を更新)
                Slider(value: $musicTime , in: 0...musicControl.audioPlayer.duration,onEditingChanged: {
                    bool in
                    if (bool == true) {
                        isChangedSlider = true
                        
                    } else {
                        // 音楽の再生位置変更
                        musicControl.changeMusicTime(musicTime: musicTime)
                        isChangedSlider = false
                    }
                }, minimumValueLabel: Text("\(timeModel.timeModeling(time: TimeInterval(Int(musicTime))))"), maximumValueLabel: Text("\(timeModel.timeModeling(time: TimeInterval(Int(musicControl.audioPlayer.duration))))"), label: {EmptyView()})
                .onReceive(timer) {
                    _ in
                    if (isChangedSlider != true) {
                        // タイマーより再生位置を更新
                        musicTime = musicControl.getMusicCurrentTime()
                    }
                }
                
                HStack {
                    Image(systemName: "play")
                        .onTapGesture {
                            // 初めての再生であれば、音楽データをセット
                            if (firstPlay == false) {
                                firstPlay = true
                                musicControl.setAudioData(fileName: musicControl.musicFiles[selectNum])
                                musicControl.audioPlay()
                            } else {
                                musicControl.audioPlay()
                            }
                        }.padding()
                    Image(systemName: "playpause")
                        .onTapGesture {
                            musicControl.audioPause()
                        }.padding()
                    Image(systemName: "pause")
                        .onTapGesture {
                            musicControl.audioStop()
                        }.padding()
                    // 音楽再生ループの設定ボタン
                    if (musicControl.audioPlayer.numberOfLoops == 0) {
                        Image(systemName: "repeat")
                            .onTapGesture {
                                musicControl.audioLoop()
                            }
                            .padding()
                    } else {
                        Image(systemName: "arrowshape.right")
                            .onTapGesture {
                                musicControl.audioLoopRelease()
                            }
                            .padding()
                    }
                }
            }
            .navigationTitle("音楽再生画面")
        }
    }
}

struct MusicListView_Previews: PreviewProvider {
    static var previews: some View {
        MusicListView().environmentObject(MusicControl())
    }
}
