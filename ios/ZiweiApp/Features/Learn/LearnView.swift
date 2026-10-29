import SwiftUI

struct LearnView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("如何阅读十二宫") { article("十二宫", "先从命宫理解核心倾向，再结合官禄、财帛、夫妻等主题宫位，最后查看三方四正。") }
                NavigationLink("什么是真太阳时") { article("真太阳时", "钟表时间依据时区，真太阳时还会结合经度与均时差。跨日或跨时辰时，本应用要求人工确认。") }
                NavigationLink("主星、辅曜与四化") { article("星曜与四化", "主星描述主要结构，辅曜增加细节，禄、权、科、忌用于观察能量如何表达。") }
                NavigationLink("如何看待命理解读") { article("使用边界", "命盘适合帮助你提出问题和整理经验，不应替代医疗、法律、财务或重大人生决策。") }
            }
            .navigationTitle("学堂")
        }
    }

    private func article(_ title: String, _ text: String) -> some View {
        ScrollView { Text(text).font(.title3).padding().frame(maxWidth: .infinity, alignment: .leading) }
            .navigationTitle(title)
    }
}
