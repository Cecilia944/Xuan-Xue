import ZiweiCore

enum CurrentCycleSummaryTests {
    static func run() {
        let chart = makeChart()
        let summary = CurrentCycleSummaryEngine.generate(
            chart: chart,
            birthYear: 1992,
            currentYear: 2026
        )

        TestSupport.equal(summary.currentYear, 2026, "summary keeps requested current year")
        TestSupport.equal(summary.nominalAge, 35, "summary calculates nominal age")
        TestSupport.equal(summary.yearGanzhi, "丙午", "summary calculates current year ganzhi")
        TestSupport.equal(summary.decadePalaceName.isEmpty, false, "summary resolves current decade palace")
        TestSupport.equal(summary.decadeText.isEmpty, false, "summary has readable decade text")
        TestSupport.equal(summary.yearText.isEmpty, false, "summary has readable year text")
        TestSupport.equal(summary.caveat.contains("确定"), true, "summary states uncertainty boundary")
        TestSupport.record(7, suite: "CurrentCycleSummaryTests")
    }

    private static func makeChart() -> ZiweiChart {
        let profile = BirthProfile(
            name: "流年样例",
            gender: .female,
            date: .gregorian(year: 1992, month: 6, day: 15),
            time: .exact(hour: 12, minute: 0)
        )
        return try! ZiweiChartEngine.generate(
            ZiweiChartRequest(
                profile: profile,
                confirmedTime: ConfirmedBirthTime(year: 1992, month: 6, day: 15, hour: 12, minute: 0, branch: 6)
            )
        )
    }
}
