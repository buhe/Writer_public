//
//  ProView.swift
//  FinanceDashboard
//
//  Created by 顾艳华 on 2023/1/22.
//

import SwiftUI
import SwiftUIX
import StoreKit

struct ProView: View {
    let title: String = "帮你写作文"
    
    @ObservedObject var viewModel: IAPViewModel = IAPViewModel.shared
    @AppStorage(wrappedValue: countInit, "count") var count: Int
    //    @ObservedObject var iap: IAPManager = IAPManager.shared
    
    var text = ""
    let by: Bool
    let close: () -> Void
    init(by: Bool, close: @escaping () -> Void) {
        self.close = close
        self.by = by
        if by {
            text = "您好，您的点数不足，请通过购买点数的方式投喂我们"
        }
    }
    var body: some View {
        if viewModel.loading {
            ActivityIndicator()
        } else {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title)
                    .bold()
                    .padding()
                
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
                        Text("重复复制")
                            .bold()
                        Text("重复复制不消耗点数。")
                    }
                }
                .padding()
                ForEach(IAPManager.shared.products.sorted(by: { $0.localizedTitle > $1.localizedTitle }), id: \.productIdentifier) {
                    item in
                    Button {
                        self.viewModel.loading = true
                        IAPManager.shared.buy(product: item)
                    } label: {
                        HStack {
                           Text(item.localizedTitle)
                           Spacer()
                           Text(item.regularPrice ?? "")
                       }
                    }
                }
                .padding()
                .onAppear {
                    IAPManager.shared.getProducts()
                }
                
                Button{
                    IAPViewModel.shared.loading = true
                    IAPManager.shared.restore()
                }label: {
                    Text("恢复订阅")
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                if by {
                    
                    Text(text)
                        .padding()
                        .bold()
                        .italic()
                } else {
                    Text("您的点数: \(count)")
                        .padding()
                        .bold()
                        .italic()
                }
         
                Text("EULA: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")
                    .padding(.horizontal)
                Text("隐私策略: https://github.com/buhe/HtmlSummary/blob/main/PrivacyPolicy.md")
                    .padding(.horizontal)
                Spacer()
                }
                .padding(.top, 100)
            }
        }
    }


struct ProView_Previews: PreviewProvider {
    static var previews: some View {
        ProView(by: false) {}
    }
}
