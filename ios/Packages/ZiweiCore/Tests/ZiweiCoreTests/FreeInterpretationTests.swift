import ZiweiCore

enum FreeInterpretationTests {
    static func run() {
        producesAllFiveCompleteReports()
        citesRealPalacesAndStars()
        avoidsDeterministicClaims()
        TestSupport.record(28, suite: "FreeInterpretationTests")
    }

    private static func producesAllFiveCompleteReports() {
        let reports = FreeInterpretationEngine.generate(chart: chart())
        TestSupport.equal(reports.map(\.topic), InterpretationCatalog.freeTopics, "engine produces all free topics in catalog order")

        for report in reports {
            TestSupport.equal(report.conclusion.isEmpty, false, "\(report.topic) has conclusion")
            TestSupport.equal(report.strengthsAndChallenges.isEmpty, false, "\(report.topic) has strengths and challenges")
            TestSupport.equal(report.evidence.isEmpty, false, "\(report.topic) has chart evidence")
            TestSupport.equal(report.action.isEmpty, false, "\(report.topic) has action advice")
        }
    }

    private static func citesRealPalacesAndStars() {
        let chart = chart()
        let reports = FreeInterpretationEngine.generate(chart: chart)

        for report in reports {
            let hasPalace = chart.palaces.contains { report.evidence.contains($0.name) }
            TestSupport.equal(hasPalace, true, "\(report.topic) evidence cites a chart palace")
        }
        let allStarNames = chart.palaces.flatMap { ($0.majorStars + $0.auxiliaryStars).map(\.name) }
        let combinedEvidence = reports.map(\.evidence).joined(separator: " ")
        TestSupport.equal(allStarNames.contains(where: combinedEvidence.contains), true, "reports cite actual chart stars")
    }

    private static func avoidsDeterministicClaims() {
        let text = FreeInterpretationEngine.generate(chart: chart())
            .flatMap { [$0.conclusion, $0.strengthsAndChallenges, $0.action] }
            .joined(separator: " ")
        TestSupport.equal(text.contains("一定会"), false, "interpretation avoids certainty claims")
        TestSupport.equal(text.contains("必然"), false, "interpretation avoids deterministic claims")
    }

    private static func chart() -> ZiweiChart {
        let profile = BirthProfile(
            name: "解读样例",
            gender: .male,
            date: .gregorian(year: 1992, month: 6, day: 15),
            time: .exact(hour: 12, minute: 0),
            location: BirthLocation(city: "北京", longitude: 116.4, utcOffsetMinutes: 480)
        )
        return try! ZiweiChartEngine.generate(
            ZiweiChartRequest(
                profile: profile,
                confirmedTime: ConfirmedBirthTime(year: 1992, month: 6, day: 15, hour: 12, minute: 0, branch: 6)
            )
        )
    }
}
