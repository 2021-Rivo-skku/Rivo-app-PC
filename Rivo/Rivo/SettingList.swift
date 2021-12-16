//
//  SettingList.swift
//  Rivo
//
//  Created by 조현우 on 2021/09/12.
//

import Foundation
import SwiftUI
import WebKit


struct Menu: Hashable {
    let title : String
}
struct SettingList: View {
    @ObservedObject var bleManager = CBController()
    @State var peripheralName: String = "disconnected"
    
    var body: some View {
        let Menu: [Menu] = [
            .init(title: "설정"),
            .init(title: "업데이트"),
            .init(title: "My리보"),
            .init(title: "도움말")
        ]
        NavigationView {
            List {
                HStack { // 현재 리보 상태 표시창
                    Text(peripheralName)
//                    if(bleManager.isConnected){
//                        Text(bleManager.peripheralName)
//                            .bold()
//                        Spacer()
//                        Text("Info.Battery")
//                            .bold()
//                    }
//                    else {
//                        Text(bleManager.peripheralName)
//                            .bold()
//                    }
                   
                }
                
                Divider()
                
                ForEach(Menu, id:\.self) {Menu in
                    NavigationLink (destination: SettingContents(menutitle: Menu.title)){
                        HStack {
                            Text(Menu.title)
                                .font(.title2)
                            Spacer() // 메뉴 타이틀 leading으로 정렬
                        }
                        .padding(10) // 메뉴 간의 간격
                    }
                }
                Spacer() // 메뉴 top으로 정렬
            }
        }
    }
}
