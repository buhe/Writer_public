//
//  WriterApp.swift
//  Writer
//
//  Created by 顾艳华 on 2023/8/5.
//

import SwiftUI
import StoreKit

@main
struct WriterApp: App {
    let persistenceController = PersistenceController.shared
    @AppStorage(wrappedValue: true, "first") var first: Bool
    @State var openNav = true
    
    var body: some Scene {
        SKPaymentQueue.default().add(IAPManager.shared)
        IAPManager.shared.getProducts()
        return WindowGroup {
            if first && openNav {
                NavContainer {
                    openNav = false
                }
            } else {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
    }
}
