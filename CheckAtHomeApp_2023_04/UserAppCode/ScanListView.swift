//
//  ScanListView.swift
//  SwiftUI_CoreBLE4
//
//  Created by 村瀬賢司 on 2023/04/06.
//

import Foundation
import SwiftUI


struct ScanListView: View {
    @EnvironmentObject var bleManager: bluetoothService
    //@AppStorage("saveUUID") var saveUUID = ""
    
    var body: some View {
        VStack {
            // ペリフェラルの探索制御ボタン
            Button(bleManager.isSearching ? "スキャンを停止する" : "スキャンを開始する"){
                if (bleManager.isSearching) {
                    bleManager.stopScanDevice()
                    
                } else {
                    bleManager.scanStart()
                }
            }
            .padding()
            
            // UUIDで登録されたペリフェラルデバイスかどうかの確認をする
            Text(bleManager.isPeripheral ? "登録済みペリフェラル発見！: \(bleManager.registerDeviceName)" : "登録されたペリフェラルは存在しない")
            
            // 発見できたペリフェラルの情報を表示
            List {
                Section {
                    ForEach(0..<bleManager.foundPeripherals.count, id: \.self) {
                        num in
                        NavigationLink(destination: RegisterDeviceInfoView(num: num)) {
                            // 発見したペリフェラルのデバイス情報を表示
                            Text("UUID: \(bleManager.foundPeripherals[num].identifier)")
                            Text("DeviceName: \(bleManager.foundPeripherals[num].name ?? "None")")
                            Text("RSSI: \(bleManager.rssi[num])")
                        }
                    }
                } header: {
                    Text("検索できたペリフェラル")
                }
            }
            .listStyle(DefaultListStyle())
            
            // サーバへ在宅or留守の通知を送信するボタン
            Button("サーバへ通知する") {
                bleManager.postAtHome()
            }
        }
        .navigationTitle("SwiftUI-BLE")
        
    }
    
    // BLEペリフェラルのデバイス情報登録画面
    struct RegisterDeviceInfoView: View {
        @EnvironmentObject var bleManager: bluetoothService
        //@AppStorage("saveUUID") var saveUUID = ""
        //@AppStorage("saveDeviceName") var saveDeviceName = ""
        var num: Int
        
        var body: some View {
            VStack {
                // UUID
                Text("UUID : \(bleManager.foundPeripherals[num].identifier)")
                Text("DeviceName : \(bleManager.foundPeripherals[num].name!)")
                //Text("rssi: \(bleManager.Rssi)")
                Text("rssi: \(bleManager.rssi[num])")
                    .padding()
                // ペリフェラルのデバイス情報登録ボタン
                Button("このペリフェラルのデバイス情報を登録する") {
                    //選択したペリフェラルのデバイス情報を登録(保存)する処理
                    bleManager.saveSelectionDeviceInfo(UUID: bleManager.foundPeripherals[num].identifier.uuidString, DeviceName: bleManager.foundPeripherals[num].name!)
                    
                }
                
            }
        }
    }
    
}

func uploadDeviceData() {
    
}


struct ScanListView_Previews: PreviewProvider {
    static var previews: some View {
        ScanListView().environmentObject(bluetoothService())
    }
}
