import ZiweiCore

enum ChartMajorStarTests {
    static func run() {
        TestSupport.equal(request((1990, 6, 15, 6, .male, 4)).schoolConfiguration.brightnessSchool, .quanshu, "defaults to Quanshu brightness school")
        let fixtures: [(Int, Int, Int, Int, Gender, Int)] = [
            (1990, 6, 15, 6, .male, 4),
            (1988, 4, 10, 0, .female, 1),
            (2000, 2, 29, 11, .male, 6),
            (2004, 2, 4, 1, .female, 8),
            (2025, 7, 2, 0, .male, 3),
        ]
        for fixture in fixtures {
            let chart = try! ZiweiChartEngine.generate(request(fixture))
            TestSupport.equal(chart.ziweiPos, fixture.5, "matches golden Ziwei position")
            TestSupport.equal(chart.palaces.flatMap(\.majorStars).count, 14, "places all fourteen major stars")
        }

        let chart = try! ZiweiChartEngine.generate(request(fixtures[0]))
        let expected: [Int: [String]] = [
            0: ["武曲", "天府"], 1: ["太阳", "太阴"], 2: ["贪狼"],
            3: ["天机", "巨门"], 4: ["紫微", "天相"], 5: ["天梁"],
            6: ["七杀"], 8: ["廉贞"], 10: ["破军"], 11: ["天同"],
        ]
        for branch in 0..<12 {
            let names = chart.palaces.first(where: { $0.branch == branch })!.majorStars.map(\.name)
            TestSupport.equal(names, expected[branch] ?? [], "matches major stars at branch \(branch)")
        }
        TestSupport.equal(star("武曲", in: chart).siHua, .quan, "applies Geng-year power transformation")
        TestSupport.equal(star("太阳", in: chart).siHua, .lu, "applies Geng-year fortune transformation")
        TestSupport.equal(star("太阴", in: chart).siHua, .ke, "applies Geng-year reputation transformation")
        TestSupport.equal(star("天同", in: chart).siHua, .ji, "applies Geng-year obstacle transformation")
        TestSupport.equal(star("武曲", in: chart).brightness, .wang, "uses Quanshu brightness table")
        TestSupport.equal(star("太阳", in: chart).brightness, .bu, "keeps weak brightness distinction")
        TestSupport.record(29, suite: "ChartMajorStarTests")
    }

    private static func request(_ value: (Int, Int, Int, Int, Gender, Int)) -> ZiweiChartRequest {
        let profile = BirthProfile(name: "fixture", gender: value.4, date: .gregorian(year: value.0, month: value.1, day: value.2), time: .approximate(branch: value.3))
        let time = ConfirmedBirthTime(year: value.0, month: value.1, day: value.2, hour: value.3 * 2, minute: 0, branch: value.3)
        return ZiweiChartRequest(profile: profile, confirmedTime: time)
    }

    private static func star(_ name: String, in chart: ZiweiChart) -> ZiweiStar {
        chart.palaces.flatMap(\.majorStars).first(where: { $0.name == name })!
    }
}
