import ZiweiCore

enum ChartStructureTests {
    static func run() {
        let cases: [(Int, Int, Int, Int, Gender, ChartSummary)] = [
            (1990, 6, 15, 6, .male, .init(lunarMonth: 5, lunarDay: 23, yearStem: 6, yearBranch: 6, ming: 0, shen: 0, ju: 6)),
            (1988, 4, 10, 0, .female, .init(lunarMonth: 2, lunarDay: 24, yearStem: 4, yearBranch: 4, ming: 3, shen: 3, ju: 2)),
            (2000, 2, 29, 11, .male, .init(lunarMonth: 1, lunarDay: 25, yearStem: 6, yearBranch: 4, ming: 3, shen: 1, ju: 5)),
            (2004, 2, 4, 1, .female, .init(lunarMonth: 1, lunarDay: 14, yearStem: 0, yearBranch: 8, ming: 1, shen: 3, ju: 2)),
            (2025, 7, 2, 0, .male, .init(lunarMonth: 6, lunarDay: 8, yearStem: 1, yearBranch: 5, ming: 7, shen: 7, ju: 3)),
        ]

        for (year, month, day, branch, gender, expected) in cases {
            let request = request(year: year, month: month, day: day, branch: branch, gender: gender)
            let chart = try! ZiweiChartEngine.generate(request)
            let actual = ChartSummary(
                lunarMonth: chart.lunarInfo.month,
                lunarDay: chart.lunarInfo.day,
                yearStem: chart.lunarInfo.yearStem,
                yearBranch: chart.lunarInfo.yearBranch,
                ming: chart.mingGongBranch,
                shen: chart.shenGongBranch,
                ju: chart.wuxingJu
            )
            TestSupport.equal(actual, expected, "matches structural golden chart for \(year)-\(month)-\(day)-\(branch)")
            TestSupport.equal(chart.palaces.count, 12, "always creates twelve palaces")
            TestSupport.equal(chart.palaces.filter(\.isMingGong).count, 1, "has exactly one life palace")
            TestSupport.equal(chart.palaces.first(where: { $0.branch == chart.mingGongBranch })?.name, "命宫", "names life palace")
        }
        TestSupport.record(20, suite: "ChartStructureTests")
    }

    private static func request(year: Int, month: Int, day: Int, branch: Int, gender: Gender) -> ZiweiChartRequest {
        let profile = BirthProfile(
            name: "fixture",
            gender: gender,
            date: .gregorian(year: year, month: month, day: day),
            time: .approximate(branch: branch)
        )
        let confirmed = ConfirmedBirthTime(
            year: year,
            month: month,
            day: day,
            hour: branch * 2,
            minute: 0,
            branch: branch
        )
        return ZiweiChartRequest(profile: profile, confirmedTime: confirmed)
    }
}

private struct ChartSummary: Equatable {
    let lunarMonth: Int
    let lunarDay: Int
    let yearStem: Int
    let yearBranch: Int
    let ming: Int
    let shen: Int
    let ju: Int
}
