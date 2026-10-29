public enum FreeInterpretationTopic: String, CaseIterable, Codable, Sendable {
    case lifePattern
    case personality
    case career
    case wealth
    case relationship
}

public enum ProInterpretationTopic: String, CaseIterable, Codable, Sendable {
    case overallPattern
    case innerNature
    case careerDevelopment
    case wealthStrategy
    case relationshipPattern
    case familyRelations
    case healthTendencies
    case learningGrowth
    case socialNetwork
    case propertyHome
    case travelMobility
    case spiritualGrowth
    case timingCycles
}

public enum FreeContentFeature: String, CaseIterable, Codable, Sendable {
    case currentYearSummary
    case currentDecadeSummary
}

public enum FreeContentAccess {
    public static func canAccess(_ feature: FreeContentFeature) -> Bool { true }
}

public enum ProFeature: String, CaseIterable, Codable, Sendable {
    case deepReport
    case fullCycles
    case aiInterpretation
    case professionalSettings
    case unlimitedProfiles
    case pdfExport
    case jsonExport
    case iCloudSync
}

public enum SubscriptionTier: String, Codable, Sendable {
    case free
    case pro
}

public protocol EntitlementProvider: Sendable {
    func canAccess(_ feature: ProFeature) -> Bool
}

public struct DefaultEntitlementProvider: EntitlementProvider {
    public let tier: SubscriptionTier

    public init(tier: SubscriptionTier) {
        self.tier = tier
    }

    public func canAccess(_ feature: ProFeature) -> Bool {
        tier == .pro
    }
}

public enum UpgradeSource: String, CaseIterable, Codable, Sendable {
    case interpretation
    case chart
    case profiles
    case export
    case settings
}

public struct UpgradeCoordinator: Sendable {
    public private(set) var pendingFeature: ProFeature?
    public private(set) var source: UpgradeSource?

    public init() {}

    public mutating func begin(feature: ProFeature, source: UpgradeSource) {
        pendingFeature = feature
        self.source = source
    }

    public mutating func completeUpgrade() -> ProFeature? {
        defer {
            pendingFeature = nil
            source = nil
        }
        return pendingFeature
    }
}

public enum PaywallPolicy {
    public static func shouldPresent(
        hasCompletedFirstChart: Bool,
        requestedFeature: ProFeature
    ) -> Bool {
        hasCompletedFirstChart
    }
}

public enum PaywallAction: String, CaseIterable, Sendable {
    case subscribeMonthly
    case subscribeYearly
    case restorePurchases
}

public struct LockedFeatureSummary: Equatable, Sendable {
    public let title: String
    public let preview: String
}

public enum InterpretationCatalog {
    public static let freeTopics = FreeInterpretationTopic.allCases
    public static let proTopics = ProInterpretationTopic.allCases

    public static func lockedSummary(for feature: ProFeature) -> LockedFeatureSummary {
        switch feature {
        case .deepReport:
            return LockedFeatureSummary(title: "13 维深度报告", preview: "从事业、关系、财富与成长等维度展开，并标注命盘依据。")
        case .fullCycles:
            return LockedFeatureSummary(title: "完整运限", preview: "查看大限、流年、流月与流日的时间脉络。")
        case .aiInterpretation:
            return LockedFeatureSummary(title: "有依据的 AI 解读", preview: "围绕已展示的星曜和宫位生成可追溯说明。")
        case .professionalSettings:
            return LockedFeatureSummary(title: "专业流派设置", preview: "调整晚子时、闰月与亮度等排盘口径。")
        case .unlimitedProfiles:
            return LockedFeatureSummary(title: "无限命盘档案", preview: "保存并管理超过三张本地命盘。")
        case .pdfExport:
            return LockedFeatureSummary(title: "PDF 报告", preview: "导出适合阅读与打印的完整报告。")
        case .jsonExport:
            return LockedFeatureSummary(title: "JSON 数据导出", preview: "导出结构化命盘数据用于专业工作流。")
        case .iCloudSync:
            return LockedFeatureSummary(title: "iCloud 同步", preview: "在你的 Apple 设备间同步命盘档案。")
        }
    }
}
