//
//  SwiftUI_DriverApp1App.swift
//  SwiftUI_DriverApp1
//
//  Created by 村瀬賢司 on 2023/04/07.
//

import SwiftUI

@main
struct SwiftUI_DriverApp1App: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(checkAtHome())
        }
    }
}
