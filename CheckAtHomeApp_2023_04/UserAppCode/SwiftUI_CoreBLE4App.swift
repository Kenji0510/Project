//
//  SwiftUI_CoreBLE4App.swift
//  SwiftUI_CoreBLE4
//
//  Created by 村瀬賢司 on 2023/04/06.
//

import SwiftUI

@main
struct SwiftUI_CoreBLE4App: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(bluetoothService())
        }
    }
}
