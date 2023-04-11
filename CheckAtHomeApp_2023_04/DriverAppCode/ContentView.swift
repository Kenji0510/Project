//
//  ContentView.swift
//  SwiftUI_DriverApp1
//
//  Created by 村瀬賢司 on 2023/04/07.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var checkAtHome_UserList: checkAtHome
    
    var body: some View {
        NavigationView {
            CheckListAtHomeView()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(checkAtHome())
    }
}
