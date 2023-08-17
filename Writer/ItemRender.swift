//
//  Sum.swift
//  Share
//
//  Created by 顾艳华 on 2023/7/5.
//

import SwiftUI

struct ItemRender: View {
    let fav: Fav
    @State var copeSuccessful = false
//    @State var showIAP = false
    let screenWidth = UIScreen.main.bounds.width
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @Environment(\.managedObjectContext) private var viewContext
    func fav(condition: Fav, isFav: Bool) -> Bool {
        switch condition {
        case .all:
            return true
        case .id(let f):
            return isFav == f
        }
    }
    var body: some View {
        List {
            ForEach(items.filter{fav(condition: self.fav, isFav: $0.fav)}) { item in
                NavigationLink {
                    ScrollView {
                        VStack(alignment: .leading) {
                            Text("题目")
                                .font(.title)
                                .bold()
                                .padding(.horizontal)
                            Text(item.ocr ?? "ocr")
                                .padding([.bottom, .horizontal])
                            Text("作文")
                                .font(.title)
                                .bold()
                                .padding(.horizontal)
                            ZStack {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.gray)
                                    .opacity(0.5)
                                    .frame(width: 44, height: 22)
                                Text("\(item.result!.count) 字")
                                    .foregroundColor(.white)
                                    .font(.caption2)
                            }
                            .padding(.horizontal)
                            .padding(.top, -16)
                            Text(item.result ?? "result")
                                .padding(.horizontal)
                        }
                        .toolbar {
                            ToolbarItem() {
                                Button{
                                    if IAPManager.shared.copyToClipboard(item: item) {
                                        copeSuccessful = true
                                    }
                                } label: {
                                    Image(systemName: "square.and.arrow.up")
                                }
                            }
                        }
                        .alert("已经复制到剪贴板中", isPresented: $copeSuccessful)  {
                            Button("知道了", role: .cancel) { }
                        }
//                        .sheet(isPresented: $showIAP) {
//                            ProView(by: true) {
//                                showIAP = false
//                            }
//                        }
                    }
                } label: {
                    VStack{
                        HStack{
                            VStack(alignment: .leading){
                                Text(item.ocr ?? "No OCR")
                                    .bold()
                                    .lineLimit(3)
                            }
                            
                            Spacer()
                            if let thumbnail = item.thumbnail1 {
                                Image(uiImage: UIImage(data: thumbnail)!)
                                    
                                    .resizable()
                                    .frame(width: 150, height: 100)
                                    .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous)
                                                    .stroke(.gray, lineWidth: 2)
                                                    .opacity(0.3)
                                             )
                            } else {
                                EmptyView()
                            }
                            
                        }
                        HStack {
                            Spacer()
                            Image(systemName: item.fav ? "bookmark.fill" : "bookmark")
                                .onTapGesture {
                                    item.fav.toggle()
                                    updateItem(item: item)
                                }
                                .padding(.horizontal)
                            Image(systemName: "trash")
                                .onTapGesture {
                                    deleteItems(item: item)
                                }
                                .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
//        .refreshable {
//            i += 1
//        }
    }
    
    private func deleteItems(item: Item) {
        withAnimation {
            viewContext.delete(item)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func updateItem(item: Item) {
        withAnimation {

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

enum Fav {
    case all
    case id(Bool)
}

