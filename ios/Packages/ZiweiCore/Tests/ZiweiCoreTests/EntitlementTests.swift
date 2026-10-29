import ZiweiCore

enum EntitlementTests {
    static func run() {
        fixesFiveFreeAndThirteenProTopics()
        grantsCurrentYearSummaryToFreeUsers()
        gatesEveryProFeatureThroughOneProvider()
        returnsToRequestedFeatureAfterUpgrade()
        avoidsPaywallBeforeFirstChart()
        providesReadableLockedSummaryAndRestoreEntry()
        TestSupport.record(30, suite: "EntitlementTests")
    }

    private static func fixesFiveFreeAndThirteenProTopics() {
        TestSupport.equal(InterpretationCatalog.freeTopics.count, 5, "catalog has five free topics")
        TestSupport.equal(
            InterpretationCatalog.freeTopics,
            [.lifePattern, .personality, .career, .wealth, .relationship],
            "free topics are stable and useful"
        )
        TestSupport.equal(InterpretationCatalog.proTopics.count, 13, "catalog has thirteen pro dimensions")
        TestSupport.equal(Set(InterpretationCatalog.proTopics).count, 13, "pro dimensions are unique")
    }

    private static func grantsCurrentYearSummaryToFreeUsers() {
        TestSupport.equal(FreeContentAccess.canAccess(.currentYearSummary), true, "current year summary is free")
        TestSupport.equal(FreeContentAccess.canAccess(.currentDecadeSummary), true, "current decade summary is free")
    }

    private static func gatesEveryProFeatureThroughOneProvider() {
        let free = DefaultEntitlementProvider(tier: .free)
        let pro = DefaultEntitlementProvider(tier: .pro)

        for feature in ProFeature.allCases {
            TestSupport.equal(free.canAccess(feature), false, "free tier blocks \(feature)")
            TestSupport.equal(pro.canAccess(feature), true, "pro tier grants \(feature)")
        }
    }

    private static func returnsToRequestedFeatureAfterUpgrade() {
        var coordinator = UpgradeCoordinator()
        coordinator.begin(feature: .aiInterpretation, source: .interpretation)

        TestSupport.equal(coordinator.pendingFeature, .aiInterpretation, "upgrade remembers requested feature")
        TestSupport.equal(coordinator.completeUpgrade(), .aiInterpretation, "upgrade returns requested feature")
        TestSupport.equal(coordinator.pendingFeature, nil, "completed upgrade clears pending feature")
    }

    private static func avoidsPaywallBeforeFirstChart() {
        TestSupport.equal(
            PaywallPolicy.shouldPresent(hasCompletedFirstChart: false, requestedFeature: .deepReport),
            false,
            "paywall never appears before first chart"
        )
        TestSupport.equal(
            PaywallPolicy.shouldPresent(hasCompletedFirstChart: true, requestedFeature: .deepReport),
            true,
            "paywall can follow an explicit locked feature request"
        )
    }

    private static func providesReadableLockedSummaryAndRestoreEntry() {
        let summary = InterpretationCatalog.lockedSummary(for: .deepReport)
        TestSupport.equal(summary.title.isEmpty, false, "locked feature has a readable title")
        TestSupport.equal(summary.preview.isEmpty, false, "locked feature has a readable preview")
        TestSupport.equal(PaywallAction.allCases.contains(.restorePurchases), true, "paywall includes restore purchases")
        TestSupport.equal(UpgradeSource.allCases.contains(.settings), true, "upgrade source includes settings")
        TestSupport.equal(UpgradeSource.allCases.contains(.chart), true, "upgrade source includes chart")
    }
}
