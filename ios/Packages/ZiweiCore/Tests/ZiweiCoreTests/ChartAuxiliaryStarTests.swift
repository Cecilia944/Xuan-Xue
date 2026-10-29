import ZiweiCore

enum ChartAuxiliaryStarTests {
    static func run() {
        let profile = BirthProfile(name: "fixture", gender: .male, date: .gregorian(year: 1990, month: 6, day: 15), time: .approximate(branch: 6))
        let time = ConfirmedBirthTime(year: 1990, month: 6, day: 15, hour: 12, minute: 0, branch: 6)
        let chart = try! ZiweiChartEngine.generate(.init(profile: profile, confirmedTime: time))
        let expected = [
            "文昌": 4, "文曲": 10, "左辅": 8, "右弼": 6,
            "天魁": 1, "天钺": 7, "禄存": 8, "天马": 8,
            "擎羊": 9, "陀罗": 7, "火星": 7, "铃星": 9,
            "地空": 5, "地劫": 5,
        ]
        let stars = chart.palaces.flatMap { palace in
            palace.auxiliaryStars.map { ($0.name, palace.branch) }
        }
        TestSupport.equal(Dictionary(uniqueKeysWithValues: stars), expected, "places fourteen key auxiliary stars")
        TestSupport.equal(auxiliary("文昌", chart).brightness, .de, "applies auxiliary Quanshu brightness")
        TestSupport.equal(auxiliary("文曲", chart).brightness, .luo, "applies weak auxiliary brightness")
        TestSupport.equal(auxiliary("地空", chart).brightness, .miao, "applies sha-star brightness")
        TestSupport.equal(auxiliary("地劫", chart).brightness, .bu, "keeps distinct earth-sha brightness")
        TestSupport.record(5, suite: "ChartAuxiliaryStarTests")
    }

    private static func auxiliary(_ name: String, _ chart: ZiweiChart) -> ZiweiStar {
        chart.palaces.flatMap(\.auxiliaryStars).first(where: { $0.name == name })!
    }
}
