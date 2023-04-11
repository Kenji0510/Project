//
//  DeviceManager.swift
//  SwiftUI_CoreBLE4
//
//  Created by 村瀬賢司 on 2023/04/06.
//

import Foundation
import CoreBluetooth


//var srvIPAddress = "192.168.0.100"//"219.122.158.86"
var srvIPAddress = "219.122.158.86"


class bluetoothService: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @Published var isSearching: Bool = false
    @Published var foundPeripherals: [CBPeripheral] = []
    @Published var peripheral: CBPeripheral!
    @Published var registerUUID: String = ""
    @Published var registerDeviceName: String = ""
    @Published var isPeripheral: Bool = false
    @Published var rssi: [NSNumber] = []
    
    var centralManager: CBCentralManager!
    
    private var timer: Timer
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch(central.state) {
        case .unknown,
            .resetting,
            .unsupported,
            .unauthorized,
            .poweredOff:
            print("PowerOff")
            break
        case .poweredOn:
            print("PowerOn")
            scanStart()
            break
        }
    }
    
    override init() {
        timer = Timer()
        registerUUID = UserDefaults.standard.string(forKey: "saveUUID") ?? ""
        registerDeviceName = UserDefaults.standard.string(forKey: "saveDeviceName") ?? ""
        super.init()
        // 定期的にサーバへデータ送信するタイマーをスタート
        timerStart()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // デバイスのスキャンを開始
    func scanStart() {
        centralManager!.scanForPeripherals(withServices: nil, options: nil)
        isSearching = true
    }
    
    // デバイスのスキャンを停止
    func stopScanDevice() {
        centralManager!.stopScan()
        isSearching = false
    }
    
    // スキャンしたデバイスの情報を格納
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var matchName: Bool = false
        
        if (nil != peripheral.name) {
            // 全ての配列のnameを比較
            for num in 0..<foundPeripherals.count {
                if (peripheral.name! == foundPeripherals[num].name!) {
                    matchName = true
                    // ペリフェラルの情報を更新
                    foundPeripherals.remove(at: num)
                    rssi.remove(at: num)
                    foundPeripherals.insert(peripheral, at: num)
                    rssi.insert(RSSI, at: num)
                }
                // 登録したペリフェラルのUUIDがあるか確認
                if (registerUUID == foundPeripherals[num].identifier.uuidString) {
                    isPeripheral = true
                }
            }
            // 重複するデバイス情報は格納しない
            if (!matchName) {
                foundPeripherals.append(peripheral)
                rssi.append(RSSI)
                
            }
            print(RSSI)
        }
    }
    
    // 選択したペリフェラルのデバイス情報を登録(保存)する処理
    func saveSelectionDeviceInfo(UUID: String, DeviceName: String) {
        // ファイルへペリフェラルのデバイス情報を保存
        UserDefaults.standard.set(UUID, forKey: "saveUUID")
        UserDefaults.standard.set(DeviceName, forKey: "saveDeviceName")
        registerUUID = UserDefaults.standard.string(forKey: "saveUUID") ?? ""
        registerDeviceName = UserDefaults.standard.string(forKey: "saveDeviceName") ?? ""
    }
    
    // タイマー処理開始関数
    func timerStart() {
        guard !timer.isValid else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) {
            _ in
            print("Timer!!")
            // 25分に一回実行
            self.postAtHome()
        }
    }
    
    // サーバへ在宅or留守の通知を送信する関数
    func postAtHome() {
        // URLの生成
        guard let url = URL(string: "http://\(srvIPAddress):3000/postAtHome") else {
            // URLが無効なケース
            print("URL is invalid!")
            return
        }
        
        // URLリクエスト（POST）
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // サーバに在宅or留守の通知データをBodyに設定
        var uploadAtHome = Dictionary<String, Any>()
        uploadAtHome["DeviceName"] = UserDefaults.standard.string(forKey: "saveDeviceName") ?? "None"
        uploadAtHome["isPeripheral"] = isPeripheral ? true : false
        uploadAtHome["UUID"] = UserDefaults.standard.string(forKey: "saveUUID") ?? "None"
        uploadAtHome["UserName"] = "Kenji4"
        uploadAtHome["Address"] = "住所２"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: uploadAtHome, options: [])
        } catch {
            print(error.localizedDescription)
        }
        
        // URLにアクセス
        URLSession.shared.dataTask(with: request) {
            data, response, error in
            if error == nil, let data = data, let response = response as? HTTPURLResponse {
                //HTTPヘッダの取得
                print("Content-Type: \(response.allHeaderFields["Content-Type"] ?? "")")
                // HTTPステータスコード
                print("statusCode: \(response.statusCode)")
            }
        }.resume()
    }
}
