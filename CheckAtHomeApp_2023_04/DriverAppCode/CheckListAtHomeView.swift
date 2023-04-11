//
//  CheckListAtHomeView.swift
//  SwiftUI_DriverApp1
//
//  Created by 村瀬賢司 on 2023/04/07.
//

import Foundation
import SwiftUI


struct CheckListAtHomeView: View {
    @EnvironmentObject var checkAtHome_UserList: checkAtHome
    
    
    var body: some View {
        VStack {
            // サーバに在宅チェックデータを問い合わせるボタン
            Button("在宅チェックを更新"){
                checkAtHome_UserList.getCheckAtHome()
            }
            .padding()
            
            // 在宅リスト
            List {
                if(checkAtHome_UserList.checkList.count != 0){
                    // 在宅リスト
                    Section {
                        ForEach(0..<checkAtHome_UserList.checkList.count, id: \.self) {
                            num in
                            if (checkAtHome_UserList.checkList[num].isPeripheral == "true") {
                                NavigationLink(destination: UserInfoView(num: num)) {
                                    Text("\(checkAtHome_UserList.checkList[num].userName): 在宅中")
                                }
                            }
                        }
                    } header: {
                        Text("在宅")
                    }
                    
                    // 留守リスト
                    Section {
                        ForEach(0..<checkAtHome_UserList.checkList.count, id: \.self) {
                            num in
                            if (checkAtHome_UserList.checkList[num].isPeripheral == "false") {
                                NavigationLink(destination: UserInfoView(num: num)) {
                                    Text("\(checkAtHome_UserList.checkList[num].userName): 留守中 ")
                                }
                            }
                        }
                    } header: {
                        Text("留守")
                    }
                }
            }
        }
        .navigationTitle("CheckAtHome_App")
        
    }
    
    // 利用者の詳細情報を表示
    struct UserInfoView: View {
        @EnvironmentObject var checkAtHome_UserList: checkAtHome
        var num: Int
        
        var body: some View {
            VStack {
                Text("利用者名: \(checkAtHome_UserList.checkList[num].userName)")
                Text("住所: \(checkAtHome_UserList.checkList[num].Address)")
            }
        }
    }
}


struct CheckListAtHomeView_Previews: PreviewProvider {
    static var previews: some View {
        CheckListAtHomeView().environmentObject(checkAtHome())
    }
}
