//
//  ItemList.swift
//  Writer
//
//  Created by 顾艳华 on 2023/8/14.
//

import SwiftUI
import CoreData
import LangChain
import LoadingView

struct ItemList: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var showSetting = false
    @State var showHelp = false
//    @State var search = ""
    @State var tabIndex = 0
    @State var imageHandlerState = ImageHandlerState.UnFound
    @State var text = ""
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    @State private var image = UIImage()
    @State private var showCameraSheet = false
    @State private var showLibSheet = false
    @State var isLoading: Bool = false
    @Binding var expect: Bool
    @Binding var illegal: Bool
    @Binding var item: Item?
    @State var showIAP = false
    
    var body: some View {
        NavigationStack {
            VStack{
                HStack {
                    Button{
                        print("Camera")
                        if IAPManager.shared.enough() || IAPManager.shared.checkSubscriptionStatus() {
                            showCameraSheet.toggle()
                        } else {
                            showIAP = true
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 25, style: .continuous)
                                .fill(.blue)
                                .opacity(0.5)
                                .shadow(radius: 10)
                                
                            Image(systemName: "camera")
                                .resizable()
                                .frame(width: 22, height: 22)
                                .foregroundStyle(.white)
                                .bold()
                        }
                        .padding(.leading)
                    }
                    .frame(width: UIScreen.screenWidth / 2)
                    Button{
                        print("Library")
                        if IAPManager.shared.enough() || IAPManager.shared.checkSubscriptionStatus(){
                            showLibSheet.toggle()
                        } else {
                            showIAP = true
                        }
                        
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 25, style: .continuous)
                                .fill(.yellow)
                                .opacity(0.5)
                                .shadow(radius: 10)
                               
                            Image(systemName: "photo")
                                .resizable()
                                .frame(width: 22, height: 22)
                                .foregroundStyle(.white)
                                .bold()
                        }
                        .padding(.trailing)
                    }
                    .frame(width: UIScreen.screenWidth / 2)
                }
                .frame(height: 100)
                .padding(.bottom)
                TabBar(tabIndex: $tabIndex)
                    .padding(.horizontal, 26)
                switch tabIndex {
                case 0:
                    ItemRender(fav: .all)
                case 1:
                    ItemRender(fav: .id(true))
                default:
                    EmptyView()
                }
            }
            .sheet(isPresented: $showCameraSheet) {
                ImagePicker(sourceType: .camera, selectedImage: self.$image)
            }
            .sheet(isPresented: $showLibSheet) {
                ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
            }
            .sheet(isPresented: $showSetting){
                Setting()
            }
            .sheet(isPresented: $showHelp){
                NavContainer{
                    showHelp = false
                }
            }
            .sheet(isPresented: $showIAP) {
                ProView(by: true) {
                    showIAP = false
                }
            }
            .toolbar {
                ToolbarItem() {
                    Button{
                        showHelp = true
                    } label: {
                        Image(systemName: "questionmark.circle")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button{
                        showSetting = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
        }
        
        .onChange(of: self.image) {
            newValue in
            print("has image")
            isLoading = true
            imageHandlerState = .Found
            text = "识别题目..."
            let data = image.pngData()!
            let ocrLoader = ImageOCRLoader(image: data)
            Task {
                let doc = await ocrLoader.load()
                let ocr = doc.first!.page_content
                print("OCR: \(ocr)")
                imageHandlerState = .OCR
                let writer_template = """
                你是个优秀的作家
                文笔尽量优美
                用排比，比喻等修辞方法
                你可以帮忙根据题目写作文
                这是作文题目:
                %@
        """
        
                let prompt_infos = [
                    [
                        "name": "writer",
                        "description": "根据题目帮忙写作文",
                        "prompt_template": writer_template,
                    ],
                    [
                        "name": "fake",
                        "description": "文字这不是作文题目"
                    ]
                ]
        
                let llm = OpenAI(temperature: 0.8)
        
                var destination_chains: [String: DefaultChain] = [:]
                let first = prompt_infos[0]
                let name = first["name"]!
                let prompt_template = first["prompt_template"]!
                let prompt = PromptTemplate(input_variables: [], template: prompt_template)
                let chain = LLMChain(llm: llm, prompt: prompt, parser: StrOutputParser())
                destination_chains[name] = chain
        
                let second = prompt_infos[1]
                let name2 = second["name"]!
                let chain2 = DNChain()
                destination_chains[name2] = chain2
        
                let default_chain = DNChain()
        
                let destinations = prompt_infos.map{
                    "\($0["name"]!): \($0["description"]!)"
                }
                let destinations_str = destinations.joined(separator: "\n")
                print("destinations_str: \(destinations_str)")
                let router_template = MultiPromptRouter.formatDestinations(destinations: destinations_str)
                let router_prompt = PromptTemplate(input_variables: [], template: router_template, output_parser: RouterOutputParser())
        
                let llmChain = LLMChain(llm: llm, prompt: router_prompt, parser: RouterOutputParser())
        
                let router_chain = LLMRouterChain(llmChain: llmChain)
        
                let mutli_chain = MultiRouteChain(router_chain: router_chain, destination_chains: destination_chains, default_chain: default_chain)
                let answer = await mutli_chain.run(args: ocr)
                DispatchQueue.main.async {
                    self.text = "生成作文..."
                }

                if answer.isEmpty {
                    print("answer is empty")
                    imageHandlerState = .Illegal("不是作文题目")
                    isLoading = false
                    illegal = true
                } else {
                    print("answer: \(answer)")
                    imageHandlerState = .Answer
                    
                    let newItem = Item(context: viewContext)
                    newItem.timestamp = Date()
                    newItem.ocr = ocr
                    newItem.result = answer
                    newItem.thumbnail1 = data
                    
                    
                    do {
                        try viewContext.save()
                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                    
                    item = newItem
                    isLoading = false
                    expect = true
                }
                
            }
        }
        .circleIndicatorWithSize(when: $isLoading, lineWidth: 5, size: 44, pathColor: .blue, lineColor: .blue, text: text)
    }
}

//#Preview {
//    ItemList()
//}

struct TabBar: View {
    @Binding var tabIndex: Int
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                TabBarButton(text: "全部", isSelected: .constant(tabIndex == 0))
                    .onTapGesture { onButtonTapped(index: 0) }
                TabBarButton(text: "收藏夹", isSelected: .constant(tabIndex == 1))
                    .onTapGesture { onButtonTapped(index: 1) }
            }
        }
//        .border(width: 1, edges: [.bottom], color: .systemGray)
    }
    
    private func onButtonTapped(index: Int) {
        withAnimation { tabIndex = index }
    }
}

struct TabBarButton: View {
    let text: String
    @Binding var isSelected: Bool
    var body: some View {
        Text(text)
            .fontWeight(isSelected ? .heavy : .regular)
            .font(.custom("Avenir", size: 16))
            .padding(.vertical, 10)
//            .border(width: isSelected ? 2 : 1, edges: [.bottom], color: .systemGray)
    }
}
