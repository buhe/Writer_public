//
//  Use.swift
//  Share
//
//  Created by 顾艳华 on 2023/7/14.
//

import SwiftUI
import AVKit

struct Use: View {
    let screenWidth = UIScreen.main.bounds.width
    let next: () -> Void
    var player = AVPlayer(url:  Bundle.main.url(forResource: "use", withExtension: "mp4")!)
    var body: some View {
        VStack {
            Text("""
            怎么使用 帮你写作文
            """)
                .font(.title)
                .bold()
                .padding()
            Text("""
1. 拍摄或在图片库中选择题目图片
2. 识别图片中的题目
3. 生成作文
""")
            .padding()
            VideoPlayer(player: player)
                .frame(width: screenWidth / 2, height: screenWidth)
                .padding()
                .onAppear() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        player.play()
                    })
                    
                    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { _ in
                                          player.seek(to: .zero)
                                          player.play()
                                      }
                }
            Button{
                next()
            }label: {
                Text("完成")
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
        .padding(.top, 40)
    }
}

struct UsePreviews: PreviewProvider {
    static var previews: some View {
        Use{}
    }
}
