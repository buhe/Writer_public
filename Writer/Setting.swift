//
//  Setting.swift
//  Share
//
//  Created by 顾艳华 on 2023/7/5.
//

import SwiftUI

struct Setting: View {
    
    @State private var showingIAP = false
    
    @AppStorage(wrappedValue: countInit, "count") var count: Int
    
    var body: some View {
        Form {
            HStack{
                Text("版本")
                Spacer()
                Text(Bundle.main.releaseVersionNumber!)
            }
            HStack{
                Text("许可证")
                Spacer()
                Text("GPLv3")
            }
            HStack {
                Text("您的点数")
                Spacer()
                Text("\(count)")
            }
            Button{
                if let url = URL(string: "itms-apps://itunes.apple.com/app/6455595076?action=write-review") {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("喜欢")
            }
            Section {
                Button{
                   showingIAP = true
                } label: {
                    
                    Text("增加点数")
                    
                }
            }
        }
        .sheet(isPresented: $showingIAP){
            ProView(by: false) {
                showingIAP = false
            }
        }
    }
}

