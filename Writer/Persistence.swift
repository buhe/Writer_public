//
//  Persistence.swift
//  Writer
//
//  Created by 顾艳华 on 2023/8/5.
//

import CoreData
import UIKit

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<2 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
//            newItem.title = "2022 沈阳高考作文题目"

            // 获取图像文件的路径
            guard let imagePath = Bundle.main.path(forResource: "sample", ofType: "png") else {
                fatalError("Image not found")
            }

            // 通过图像文件的路径创建UIImage对象
            guard let image = UIImage(contentsOfFile: imagePath) else {
                fatalError("Unable to create image")
            }

            // 将UIImage对象转换为图像数据
            if let imageData = image.pngData() {
                // 在这里可以使用图像数据做一些处理
                print("Image data: \(imageData)")
                newItem.thumbnail1 = imageData
            } else {
                fatalError("Unable to convert image to data")
            }
            newItem.ocr = """
    请以“我是如此地热爱 ”为题，写一篇文章。
    要求：①把题目补充完整，然后作文；②文体自选（诗歌除外）；③600字以上；④文中不能出现考生的姓名和所在学校名称。
    """
            newItem.result = """
    我是如此地热爱

    我是如此地热爱，仿佛一颗炽热的火焰，燃烧在心灵深处，驱散着一切迷茫和犹豫。

    我热爱生活，热爱这个世界上的一切美好。每当清晨的阳光洒满大地，我仿佛感受到大自然的温暖拥抱，感受到生命的蓬勃跃动。我热爱大自然的奇妙和壮丽，热爱蓝天白云下自由翱翔的鸟儿，热爱青山绿水间绽放的花朵。我希望能够与大自然紧密相连，倾听山林的声音，流连于花海之中，感受生命的跳动与脉搏。

    我热爱人与人之间的情感纽带，热爱那些真诚的笑容和温暖的关怀。每当我与朋友或家人相聚时，我能够感受到爱在心间流淌，情谊在岁月里沉淀。我热爱那些不离不弃的友谊，热爱那些懂得分享与包容的人。他们给了我力量和勇气，让我能够坚定地面对生活的挑战，也让我体会到爱是多么伟大和宝贵。

    我热爱知识，热爱不断追求智慧的旅程。每当我打开一本书，踏上学习的道路，我仿佛进入了一个奇幻的世界，探索着知识的深渊。我热爱那些智慧的结晶，热爱那些照亮前行的明灯。我相信知识会改变命运，也相信智慧会让我们更加深刻地理解这个世界。我愿意用自己的双手去追寻知识，用自己的智慧去改变世界。

    我热爱梦想，热爱那个激情燃烧的追逐。每当我闭上眼睛，想象着未来的景象，我仿佛能够看到那个充满希望和可能的世界。我热爱那些勇敢追梦的人，热爱那些敢于挑战自我的人。我相信梦想是每个人心中的火焰，它能够驱散黑暗和迷茫，点亮前行的道路。我愿意用自己的努力去追逐梦想，用自己的勇气去实现梦想。

    我是如此地热爱，热爱生活中的一切美好和真善美。热爱让我感受到生命的力量和温暖，热爱让我勇敢面对挑战和困难。无论前方的道路如何坎坷，我都愿意坚定地走下去，用热爱点亮心灵的火焰，让生活在光芒中绽放！
    """
            
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Writer")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
