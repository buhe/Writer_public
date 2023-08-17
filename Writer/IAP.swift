//
//  IAP.swift
//  FinanceDashboard
//
//  Created by 顾艳华 on 2023/1/17.
//

import Foundation

import SwiftUI

import StoreKit

class IAPManager: NSObject, ObservableObject {
    @AppStorage(wrappedValue: countInit, "count") var count: Int
    
    static let shared = IAPManager()
    @Published var products = [SKProduct]()
    fileprivate var productRequest: SKProductsRequest!
    func getProductID() -> [String] {
        ["dev.buhe.writer.1", "dev.buhe.writer.10", "dev.buhe.writer.monthly"]
    }
    
    func checkSubscriptionStatus() -> Bool {
        
        let semaphore = DispatchSemaphore(value: 0)
        let request = SKReceiptRefreshRequest()
//        request.delegate = self
        request.start()
        var vaild = true
        #if DEBUG
            print("Debug mode")
            let storeURL = URL(string: "https://sandbox.itunes.apple.com/verifyReceipt")
        #else
            print("Release mode")
            let storeURL = URL(string: "https://buy.itunes.apple.com/verifyReceipt")
        #endif
        print("store url: \(storeURL!.absoluteString)")
        
        if let receiptUrl = Bundle.main.appStoreReceiptURL {
            do {
                let receiptData = try Data(contentsOf: receiptUrl)
                let receiptString = receiptData.base64EncodedString(options: [])
                let requestContents = ["receipt-data": receiptString,
                                       "password": "b88da180c68645628dfd460ba61de270"]

                let requestData = try JSONSerialization.data(withJSONObject: requestContents,
                                                              options: [])
                
                var request = URLRequest(url: storeURL!)
                request.httpMethod = "POST"
                request.httpBody = requestData

                let session = URLSession.shared
                let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
                    if let data = data {
                        do {
                            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                                let receiptInfo = jsonResponse["latest_receipt_info"] as? [[String: Any]] {
                                let last = receiptInfo.first!
                                let expires = Int(last["expires_date_ms"] as! String)!
                                let now = Date()
                                
                                let utcMilliseconds = Int(now.timeIntervalSince1970 * 1000)
                                if utcMilliseconds > expires {
                                    // timeout
                                    vaild = false
                                }
                            }
                        } catch {
                            print("Pasre server error: \(error)")
                        }
                    }
                    
                    semaphore.signal()
                })
                task.resume()
            } catch {
                print("Can not load receipt：\(error), user not subscriptio.")
                vaild = false
                semaphore.signal()
            }
            
        } else {
            vaild = false
            semaphore.signal()
        }
        semaphore.wait()
        return vaild
    }
    
    func getProducts() {
        let productIds = getProductID()
        let productIdsSet = Set(productIds)
        productRequest = SKProductsRequest(productIdentifiers: productIdsSet)
        productRequest.delegate = self
        productRequest.start()
    }
    
    func buy(product: SKProduct) {
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            // show error
        }
    }
    
    func restore() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func enough() -> Bool {
        if count - 1 >= 0 {
            count -= 1
            return true
        } else {
            return false
        }
    }
    
    func copyToClipboard(item: Item) -> Bool {
        //
//        if item.iap {
//            UIPasteboard.general.string = item.result
//            return true
//        } else if count - 1 > 0 {
            UIPasteboard.general.string = item.result
//            item.iap = true
//            count -= 1
//            do {
//                try PersistenceController.shared.container.viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }

            return true
//        } else {
//            return false
//        }
    }

}
extension IAPManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        response.products.forEach {
            print($0.localizedTitle, $0.price, $0.localizedDescription)
        }
        DispatchQueue.main.async {
           self.products = response.products
       }
    }
    
}

extension IAPManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        transactions.forEach {
            print($0.payment.productIdentifier, $0.transactionState.rawValue)
            switch $0.transactionState {
            case .purchased:
                IAPViewModel.shared.loading = false
                SKPaymentQueue.default().finishTransaction($0)
                if $0.payment.productIdentifier == "dev.buhe.writer.1" {
                    count += 1
                }
                if $0.payment.productIdentifier == "dev.buhe.writer.10" {
                    count += 10
                }
            case .failed:
                print($0.error ?? "")
                if ($0.error as? SKError)?.code != .paymentCancelled {
                    // show error
                }
              SKPaymentQueue.default().finishTransaction($0)
                IAPViewModel.shared.loading = false
            case .restored:
                //
//                Setting.shared.iap = true
                IAPViewModel.shared.loading = false
              SKPaymentQueue.default().finishTransaction($0)
            case .purchasing, .deferred:
                break
            @unknown default:
                break
            }
            
        }
    }
    
}

extension SKProduct {
    var regularPrice: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)
    }
}


//struct ProductList: View {
//
//    @ObservedObject var iapManager = IAPManager.shared
//
//    var body: some View {
//
//        List(iapManager.products, id: \.productIdentifier) { (product)  in
//            Button(action: {
//                self.iapManager.buy(product: product)
//}) {
//                HStack {
//                    Text(product.productIdentifier)
//                    Spacer()
//                    Text(product.regularPrice ?? "")
//                }
//            }
//        }
//        .onAppear {
//            self.iapManager.getProducts()
//        }
//    }
//}
