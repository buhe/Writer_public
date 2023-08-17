//
//  ContentView.swift
//  Writer
//
//  Created by 顾艳华 on 2023/8/5.
//

import SwiftUI
import CoreData
import LangChain
import LoadingView

struct ContentView: View {

    let context = PersistenceController.shared.container.viewContext
    
    @AppStorage(wrappedValue: true, "first") var first: Bool
   
    @State var expect = false
    @State var illegal = false
    @State var item: Item? = nil
    
    @State var copeSuccessful = false

    
    init() {
        if first {
            createWelcomeData()
            workaroundChinaSpecialBug()
            first = false
        }
    }
    var body: some View {
        if expect {
            ScrollView {
                VStack(alignment: .leading){
                    HStack {
                        Spacer()
                        Button {
                            expect = false
                        } label: {
                            Image(systemName: "xmark.circle")
                        }
                        .font(.title2)
                        .padding()
                    }
                    Text("题目")
                        .font(.title)
                        .bold()
                        .padding(.horizontal)
                    Text(item!.ocr ?? "ocr")
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
                        Text("\(item!.result!.count) 字")
                            .foregroundColor(.white)
                            .font(.caption2)
                    }
                    .padding(.horizontal)
                    .padding(.top, -16)
                    Text(item!.result ?? "result")
                        .padding(.horizontal)
                    // 1. expect result
                    // 2. iap
                    Button{
                        if IAPManager.shared.copyToClipboard(item: item!) {
                            copeSuccessful = true
                        } 
                    } label:{
                        Text("复制到剪贴板")
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                    
                }
                .alert("已经复制到剪贴板中", isPresented: $copeSuccessful)  {
                    Button("知道了", role: .cancel) { }
                }
                
                
            }
            
        } else {
            ItemList(expect: $expect, illegal: $illegal, item: $item)
                .alert("图片里可能不含题目，麻烦重新扫描或换个角度", isPresented: $illegal)  {
                    Button("知道了", role: .cancel) { }
                }
        }
      
    }

    private func createWelcomeData() {
        let _1 = Item(context: context)
        _1.timestamp = Date()
        if let imageData = getImage(name: "1").pngData() {
            // 在这里可以使用图像数据做一些处理
            print("Image data: \(imageData)")
            _1.thumbnail1 = imageData
        } else {
            fatalError("Unable to convert image to data")
        }
//        _1.title = "2022 天津市高考作文题"
        _1.ocr = """
作文（50分）
“野火烧不尽，春风吹又生”是小草的坚韧；“千磨万击还坚劲，任尔东西南北风”是竹子的坚韧。坚韧的精神，不仅在于“坚毅、勇敢”，更强调“韧性、韧劲”。生命需要韧劲。有韧劲的人，无论身处怎样的困境，都能坚定信心，坦然面对，勇敢前行；没有韧劲的人，遇到困难时，往往灰心气馁，畏缩不前，一事难成。同学们，你有怎样的经历和感受呢？
请自拟题目，自选角度，写一篇文章。
要求：（1）紧扣主题，内容具体充实；（2）有真情实感；（3）文体不限（诗歌、戏剧除外）；（4）不少于600字；（5）文中请回避与你相关的人名、校名、地名。
"""
        _1.result = """
坚韧之光，照亮前行路

野火烧不尽，春风吹又生；千磨万击还坚劲，任尔东西南北风。这些诗句中的坚韧，是大自然赋予了小草和竹子的品质。坚韧是一种精神力量，是生命中必不可少的品质。在生活中，我遇到了许多困难和挫折，但正是坚韧的力量，让我能够克服困难，继续向前。

我记得小时候，我梦想成为一名画家。然而，我在绘画方面的天赋并不出众，刚开始画的画总是稚嫩而生涩。朋友们嘲笑我，说我不擅长绘画，让我感到挫败和沮丧。但我没有放弃，我看到了画家们作品中那种感人的魅力，我渴望能够用画笔表达自己的情感和想法。于是，我默默地坚持练习，不断尝试，用心观察生活中的美好事物。每一幅画都是我用坚韧和努力换来的，虽然不是非常完美，但我能感到进步和成长，这让我更加坚定地追求自己的梦想。

坚韧不仅在学习和事业上发挥作用，在生活的各个方面都是如此。家庭关系中，父母的离异给我的童年带来了许多困扰和痛苦。我曾经陷入了自卑和无助的情绪，好像世界崩塌了一般。但是我并没有选择放弃，我要坚持寻找快乐和希望。我开始参加各种兴趣班，结交新的朋友，努力提升自己的心理素质。我用坚韧的态度面对家庭的变故，坚信自己可以克服困境，过上自己理想中的生活。

坚韧的力量也在面对学业困难时发挥作用。高中阶段是繁忙而艰辛的，学习压力大，竞争激烈。我曾一度感到力不从心，觉得自己无法应对这样的挑战。但是，在老师和家人的鼓励下，我选择了坚持和努力。我制定了合理的学习计划，培养了良好的学习习惯，寻求了同学和老师的帮助。尽管有时遇到挫折和失败，但是我没有退缩，而是用坚韧的精神重新站起来，继续奋斗。

坚韧如同一个不灭的火焰，在我心中燃烧着。每当我遇到困境和挫折时，我都会想起小草和竹子的坚韧，我会鼓励自己要像它们一样顽强不屈。坚韧给了我无穷的力量，让我能够坚定信心，勇敢面对各种挑战。生命中有了韧劲，就能在逆境中寻找到曙光，就能够不断成长和进步。我相信，只要我保持坚韧的品质，任何困难都不可怕，我的未来将会因此而更加美好。
"""
        
        let _2 = Item(context: context)
        _2.timestamp = Date()
        if let imageData = getImage(name: "2").pngData() {
            // 在这里可以使用图像数据做一些处理
            print("Image data: \(imageData)")
            _2.thumbnail1 = imageData
        } else {
            fatalError("Unable to convert image to data")
        }
//        _2.title = "2022 重庆市高考作文题"
        _2.ocr = """
以下两题，选做一题。（55分）
要求：①不少于500字；②凡涉及真实的人名、校名、地名，一律用A、B、C等英文大写字母代替；③不得抄袭。
（1）“济”是2022年年度推荐热词之一。“济”（jì），本义为过河，如“同舟共济”，比喻同心协力战胜困难；引申为救济，如“接济”；又引申为补益，如“刚柔并济”。
请围绕“济”字的含义，自拟题目，写一篇文章，除诗歌外，文体不限。
（2）相识如昨，离别在即。回首过往，几多感慨，几多惆怅……同学都有许多的话想要倾诉。为此，你班将举行一次毕业晚会。参加晚会的有尊敬的老师，亲爱的父母，朝夕相伴的同学。
你将代表全班同学在晚会上发言，请写一篇发言稿。注意：在作文答卷第一行居中写明“毕业晚会发言稿”。
"""
        _2.result = """
毕业晚会发言稿

尊敬的各位老师，亲爱的父母，亲爱的同学们：

大家好！在这个激动人心的时刻，我有幸代表全班同学发表毕业晚会的发言。首先，我想对所有的老师们表示由衷的感谢。是你们的辛勤教诲和悉心指导，让我们成长为更好的自己。在这三年的求知路上，您们像明灯一样给予我们指引，让我们不再迷茫，在挫折中坚持，在学习中前进。您们的付出和教诲将伴随我们一生，感谢您们！

亲爱的父母们，您们是我们最坚实的后盾。我们在未知的道路上前行，有时会迷失方向，但您们总是默默支持着我们。您们给了我们无数的爱和温暖，为我们创造了一个安全、舒适的环境，让我们有勇气去追逐自己的梦想。没有您们的付出和支持，我们不可能走到今天。感谢您们的呵护与付出！

还有我们最亲密的伙伴，亲爱的同学们。我们一起度过了心动的初次相识，一起度过了甜蜜的友谊，一起度过了欢笑与眼泪。在这三年的时光里，我们一起走过了风风雨雨，一起经历了成长的痛苦和快乐。我们彼此扶持，相互鼓励，共同追求着梦想的脚步。我们的友谊如同璀璨的星空，照耀着我们前行的道路。

相识如昨，离别在即。回首往事，我们有许多的话想要倾诉。这里有无数个回忆，它们承载了我们的青春，记录了我们的成长。我们曾一起拼搏，一起奋斗，一起憧憬未来。虽然我们要告别校园，但是友谊永存。即便走向不同的天涯，我们也是永远的朋友。

在这个特殊的时刻，我们要怀揣感激和思念，怀揣对过去的珍惜和遗憾，怀揣对未来的希冀和期待。让我们共同回忆起那些美好的瞬间，共同展望着那片遥远的蓝天。相信我们的未来会更加辉煌灿烂，我们的友谊会更加坚不可摧。让我们用心感受这一刻的激动与温馨，让我们共同怀揣着美好并勇敢地向前迈进。

最后，我衷心祝愿我们班的同学们在未来的道路上，能够拥有坚韧不拔的意志，迎接挑战，勇往直前。祝愿我们的老师们事业有成，幸福快乐。祝愿我们的父母们健康幸福，一切顺利。让我们在新的征程上，相互支持，共同成长，在未来的岁月里绽放出属于我们自己的精彩！

谢谢大家！
"""
        
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

    }
    
    private func getImage(name: String) -> UIImage {
        // 获取图像文件的路径
        guard let imagePath = Bundle.main.path(forResource: name, ofType: "webp") else {
            fatalError("Image not found")
        }

        // 通过图像文件的路径创建UIImage对象
        guard let image = UIImage(contentsOfFile: imagePath) else {
            fatalError("Unable to create image")
        }

        return image
    }
    
    fileprivate func workaroundChinaSpecialBug() {
        let url = URL(string: "https://www.baidu.com")!
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let _ = data else { return }
//            print(String(data: data, encoding: .utf8)!)
        }
        
        task.resume()
    }
}


struct ContentPreviews: PreviewProvider {
    static var previews: some View {        
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
