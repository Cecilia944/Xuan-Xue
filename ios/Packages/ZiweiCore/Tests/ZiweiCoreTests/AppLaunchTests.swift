import ZiweiCore

enum AppLaunchTests {
    static func run() {
        TestSupport.equal(
            AppRootRouter.destination(profileCount: 0),
            .onboarding,
            "no profiles starts onboarding"
        )
        TestSupport.equal(
            AppRootRouter.destination(profileCount: 1),
            .mainTabs([.today, .chart, .interpretation, .learn, .profile]),
            "existing profile starts with all five root tabs"
        )
        TestSupport.record(2, suite: "AppLaunchTests")
    }
}
