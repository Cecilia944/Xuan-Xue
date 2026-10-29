public struct FreeInterpretationReport: Equatable, Sendable {
    public let topic: FreeInterpretationTopic
    public let title: String
    public let conclusion: String
    public let strengthsAndChallenges: String
    public let evidence: String
    public let action: String
}

public enum FreeInterpretationEngine {
    public static func generate(chart: ZiweiChart) -> [FreeInterpretationReport] {
        InterpretationCatalog.freeTopics.map { topic in
            let palace = relevantPalace(for: topic, in: chart)
            let framing = copy(for: topic)
            return FreeInterpretationReport(
                topic: topic,
                title: framing.title,
                conclusion: framing.conclusion,
                strengthsAndChallenges: framing.strengthsAndChallenges,
                evidence: evidence(for: palace),
                action: framing.action
            )
        }
    }

    private static func relevantPalace(
        for topic: FreeInterpretationTopic,
        in chart: ZiweiChart
    ) -> ZiweiPalace {
        let name: String
        switch topic {
        case .lifePattern, .personality: name = "命宫"
        case .career: name = "官禄"
        case .wealth: name = "财帛"
        case .relationship: name = "夫妻"
        }
        return chart.palaces.first(where: { $0.name == name }) ?? chart.palaces[0]
    }

    private static func evidence(for palace: ZiweiPalace) -> String {
        let stars = palace.majorStars + palace.auxiliaryStars
        if !stars.isEmpty {
            let names = stars.prefix(4).map(\.name).joined(separator: "、")
            return "命盘依据：\(palace.name)位于地支 \(branchName(palace.branch))，可见星曜 \(names)。"
        }
        if !palace.borrowedMajorStars.isEmpty {
            return "命盘依据：\(palace.name)为空宫，参考对宫的 \(palace.borrowedMajorStars.joined(separator: "、"))。"
        }
        return "命盘依据：\(palace.name)位于地支 \(branchName(palace.branch))，需结合三方四正综合阅读。"
    }

    private static func branchName(_ branch: Int) -> String {
        ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"][branch]
    }

    private static func copy(
        for topic: FreeInterpretationTopic
    ) -> (title: String, conclusion: String, strengthsAndChallenges: String, action: String) {
        switch topic {
        case .lifePattern:
            return (
                "命格概览",
                "你的命盘呈现出一组稳定的核心倾向，但它更适合用来理解选择方式，而不是替你决定结果。",
                "优势在于能沿着自身节奏积累；课题是避免只依赖熟悉路径，并给环境变化留下空间。",
                "回顾最近三次重要选择，记录哪些做法最符合你的长期价值，再选一项继续投入。"
            )
        case .personality:
            return (
                "性格与内在动力",
                "你可能同时拥有对外呈现与内在需求两个层次，独处时的真实感受值得被认真看见。",
                "优势是自我观察后能形成清晰判断；课题是压力大时不要把谨慎变成过度自我怀疑。",
                "本周安排一次不被打断的复盘，分别写下“我想要”和“别人期待”各三项。"
            )
        case .career:
            return (
                "事业与发展方式",
                "职业发展更适合结合长期能力积累与阶段性机会，不宜只用职位高低衡量进展。",
                "优势是能在明确目标下持续推进；课题是及时补足协作、表达或转换赛道所需的能力。",
                "选择未来三个月最关键的一项职业能力，为它设定每周可检查的练习成果。"
            )
        case .wealth:
            return (
                "财富与资源管理",
                "财富主题反映你调度资源的偏好，并不等同于固定的收入上限或投资结果。",
                "优势是能在理解规则后建立自己的节奏；课题是区分长期配置、日常现金流和高风险尝试。",
                "先建立三个月收支记录和应急金目标，再评估任何需要承担明显波动的决定。"
            )
        case .relationship:
            return (
                "感情与相处模式",
                "关系中的需求与互动模式可能随阶段变化，命盘提供的是观察角度，而不是对伴侣或结果的判定。",
                "优势是愿意在信任建立后投入；课题是把期待说清楚，并允许双方保留边界和调整空间。",
                "用一次具体对话表达“我感受到、我需要、我愿意”，避免用猜测替代确认。"
            )
        }
    }
}
