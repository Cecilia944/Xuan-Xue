import ZiweiCore

@main
enum AppLaunchTests {
    static func main() {
        assertEqual(
            AppRootRouter.destination(profileCount: 0),
            .onboarding,
            "no profiles starts onboarding"
        )
        assertEqual(
            AppRootRouter.destination(profileCount: 1),
            .mainTabs([.today, .chart, .interpretation, .learn, .profile]),
            "existing profile starts with all five root tabs"
        )
        print("AppLaunchTests: 2 passed")
    }

    private static func assertEqual<T: Equatable>(_ actual: T, _ expected: T, _ name: String) {
        guard actual == expected else {
            fatalError("FAIL \(name): expected \(expected), got \(actual)")
        }
    }
}
