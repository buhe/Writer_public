//
//  Welcome.swift
//  Share
//
//  Created by 顾艳华 on 2023/7/14.
//

import SwiftUI

struct Welcome: View {
    @AppStorage(wrappedValue: countInit, "count") var count: Int
    let next: () -> Void
    
    var body: some View {
        VStack {
            Text("欢迎使用 帮你写作文")
                .font(.title)
                .bold()
                .padding()
            VStack(alignment: .leading){
                Text("""
使用 AI 技术帮你写作文
""")
                HStack{
                    Image(systemName: "dice")
                    VStack(alignment: .leading){
                        Text("AI 生成")
                            .bold()
                        Text("AI 生成，相同的题目每个人生成不同的作文。")
                    }
                }
                .padding()
                HStack{
                    Image(systemName: "square.and.arrow.up.fill").padding(.trailing, 8)
                    VStack(alignment: .leading){
                        Text("复制")
                            .bold()
                        Text("复制到剪贴板中，进而您可以粘贴到您喜爱的应用中。")
                    }
                }
                .padding()
            }.padding()
            Text("您有 \(count) 次免费试用。")
                .bold()
                .italic()
                .padding()
            Button{
                next()
            }label: {
                Text("继续")
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
        .padding(.top, 100)
    }
}

struct Welcome_Previews: PreviewProvider {
    static var previews: some View {
        Welcome{}
    }
}
