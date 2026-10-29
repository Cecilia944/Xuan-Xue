public enum RootTab: String, CaseIterable, Sendable {
    case today
    case chart
    case interpretation
    case learn
    case profile
}

public enum AppRoute: Equatable, Sendable {
    case onboarding
    case mainTabs([RootTab])
}

public enum AppRootRouter {
    public static func destination(profileCount: Int) -> AppRoute {
        guard profileCount > 0 else { return .onboarding }
        return .mainTabs(RootTab.allCases)
    }
}
