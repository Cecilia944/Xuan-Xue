public struct SharePrivacyOptions: Equatable, Sendable {
    public let includeNickname: Bool

    public init(includeNickname: Bool = false) {
        self.includeNickname = includeNickname
    }

    public static let `default` = SharePrivacyOptions()
}

public struct ChartSharePalace: Equatable, Sendable {
    public let name: String
    public let branch: String
    public let stars: [String]
}

public struct ChartShareContent: Equatable, Sendable {
    public let nickname: String?
    public let birthTimeLabel: String
    public let chartTitle: String
    public let palaceSummaries: [ChartSharePalace]

    public var searchableText: String {
        let palaceText = palaceSummaries.flatMap { [$0.name, $0.branch] + $0.stars }
        return ([nickname, birthTimeLabel, chartTitle].compactMap { $0 } + palaceText)
            .joined(separator: " ")
    }
}

public enum ChartShareContentBuilder {
    public static let requiresNetwork = false

    public static func build(
        record: ChartRecord,
        privacy: SharePrivacyOptions = .default
    ) -> ChartShareContent {
        let branches = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]
        let palaces = record.chart.palaces.map { palace in
            ChartSharePalace(
                name: palace.name,
                branch: branches[palace.branch],
                stars: (palace.majorStars + palace.auxiliaryStars).map(\.name)
            )
        }
        return ChartShareContent(
            nickname: privacy.includeNickname ? record.profile.name : nil,
            birthTimeLabel: "\(branches[record.confirmedTime.branch])时",
            chartTitle: "紫微斗数本命盘",
            palaceSummaries: palaces
        )
    }
}
