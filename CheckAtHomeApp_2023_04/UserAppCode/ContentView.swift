//
//  ContentView.swift
//  SwiftUI_CoreBLE4
//
//  Created by 村瀬賢司 on 2023/04/06.
//

import SwiftUI


struct ContentView: View {
    @EnvironmentObject var bleManager: bluetoothService
    //@AppStorage("saveUUID") var saveUUID = ""
    
    var body: some View {
        NavigationView {
            ScanListView()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(bluetoothService())
    }
}
