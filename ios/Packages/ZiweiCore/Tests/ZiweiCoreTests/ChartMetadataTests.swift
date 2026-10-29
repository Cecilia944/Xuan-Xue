import ZiweiCore

enum ChartMetadataTests {
    static func run() {
        let male = try! ZiweiChartEngine.generate(request(1990, 6, 15, 6, .male))
        TestSupport.equal(male.mingZhu, "贪狼", "derives life ruler from life palace")
        TestSupport.equal(male.shenZhu, "火星", "derives body ruler from birth-year branch")
        TestSupport.equal(male.yinYangGender, "阳男", "labels yin-yang gender")
        TestSupport.equal(palace(0, male).daXianAge, AgeRange(start: 6, end: 15), "starts decade at bureau number")
        TestSupport.equal(palace(1, male).daXianAge, AgeRange(start: 16, end: 25), "yang male decades move forward")
        TestSupport.equal(palace(7, male).borrowedFromBranch, 1, "empty palace borrows opposite palace")
        TestSupport.equal(palace(7, male).borrowedMajorStars, ["太阳", "太阴"], "structures borrowed major stars")

        let female = try! ZiweiChartEngine.generate(request(1988, 4, 10, 0, .female))
        TestSupport.equal(female.yinYangGender, "阳女", "labels yang female")
        TestSupport.equal(palace(3, female).daXianAge, AgeRange(start: 2, end: 11), "starts female decade at bureau number")
        TestSupport.equal(palace(2, female).daXianAge, AgeRange(start: 12, end: 21), "yang female decades move backward")

        let yinMale = try! ZiweiChartEngine.generate(request(2025, 7, 2, 0, .male))
        TestSupport.equal(yinMale.yinYangGender, "阴男", "labels yin male")
        TestSupport.equal(palace(6, yinMale).daXianAge, AgeRange(start: 13, end: 22), "yin male decades move backward")
        TestSupport.record(12, suite: "ChartMetadataTests")
    }

    private static func request(_ year: Int, _ month: Int, _ day: Int, _ branch: Int, _ gender: Gender) -> ZiweiChartRequest {
        let profile = BirthProfile(name: "fixture", gender: gender, date: .gregorian(year: year, month: month, day: day), time: .approximate(branch: branch))
        return ZiweiChartRequest(profile: profile, confirmedTime: .init(year: year, month: month, day: day, hour: branch * 2, minute: 0, branch: branch))
    }

    private static func palace(_ branch: Int, _ chart: ZiweiChart) -> ZiweiPalace {
        chart.palaces.first(where: { $0.branch == branch })!
    }
}
