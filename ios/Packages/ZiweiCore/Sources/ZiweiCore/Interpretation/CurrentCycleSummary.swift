public struct CurrentCycleSummary: Equatable, Sendable {
    public let currentYear: Int
    public let nominalAge: Int
    public let yearGanzhi: String
    public let decadePalaceName: String
    public let decadeText: String
    public let yearText: String
    public let caveat: String
}

public enum CurrentCycleSummaryEngine {
    public static func generate(
        chart: ZiweiChart,
        birthYear: Int,
        currentYear: Int
    ) -> CurrentCycleSummary {
        let age = max(1, currentYear - birthYear + 1)
        let palace = chart.palaces.first { palace in
            guard let range = palace.daXianAge else { return false }
            return range.start...range.end ~= age
        } ?? chart.palaces.first(where: { $0.isMingGong }) ?? chart.palaces[0]
        let stars = (palace.majorStars + palace.auxiliaryStars).prefix(4).map(\.name)
        let evidence = stars.isEmpty ? "结合三方四正" : "参考 \(stars.joined(separator: "、"))"
        let ganzhi = yearGanzhi(currentYear)

        return CurrentCycleSummary(
            currentYear: currentYear,
            nominalAge: age,
            yearGanzhi: ganzhi,
            decadePalaceName: palace.name,
            decadeText: "当前约 \(age) 岁，行运重点落在\(palace.name)，\(evidence)。适合把长期目标拆成可复盘的阶段行动。",
            yearText: "\(currentYear) 年为 \(ganzhi) 年。流年摘要用于观察今年的注意力与选择节奏，重要决定仍应结合现实条件。",
            caveat: "运限与流年不代表确定事件，也不替代医疗、法律、财务或其他专业建议。"
        )
    }

    private static func yearGanzhi(_ year: Int) -> String {
        let stems = ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"]
        let branches = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]
        return stems[positiveModulo(year - 4, 10)] + branches[positiveModulo(year - 4, 12)]
    }

    private static func positiveModulo(_ value: Int, _ divisor: Int) -> Int {
        ((value % divisor) + divisor) % divisor
    }
}
