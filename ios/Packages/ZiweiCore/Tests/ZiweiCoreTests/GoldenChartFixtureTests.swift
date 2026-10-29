import Foundation
import ZiweiCore

enum GoldenChartFixtureTests {
    static func run() {
        let url = Bundle.module.url(forResource: "golden-charts", withExtension: "json", subdirectory: "Fixtures")!
        let fixtures = try! JSONDecoder().decode([GoldenChart].self, from: Data(contentsOf: url))
        TestSupport.equal(fixtures.count, 5, "loads all five cross-language golden charts")
        for fixture in fixtures {
            let profile = BirthProfile(
                name: fixture.id,
                gender: fixture.gender,
                date: .gregorian(year: fixture.year, month: fixture.month, day: fixture.day),
                time: .approximate(branch: fixture.branch)
            )
            let confirmed = ConfirmedBirthTime(
                year: fixture.year,
                month: fixture.month,
                day: fixture.day,
                hour: fixture.branch * 2,
                minute: 0,
                branch: fixture.branch
            )
            let chart = try! ZiweiChartEngine.generate(.init(profile: profile, confirmedTime: confirmed))
            TestSupport.equal(chart.mingGongBranch, fixture.mingGongBranch, "\(fixture.id) life palace")
            TestSupport.equal(chart.shenGongBranch, fixture.shenGongBranch, "\(fixture.id) body palace")
            TestSupport.equal(chart.wuxingJu, fixture.wuxingJu, "\(fixture.id) five-element bureau")
            TestSupport.equal(chart.ziweiPos, fixture.ziweiPos, "\(fixture.id) Ziwei position")
            let actualStars = Dictionary(uniqueKeysWithValues: chart.palaces.map { ($0.branch, $0.majorStars.map(\.name)) })
            TestSupport.equal(actualStars, fixture.majorStars, "\(fixture.id) major stars by palace")
            let actualAuxiliary = Dictionary(uniqueKeysWithValues: chart.palaces.flatMap { palace in
                palace.auxiliaryStars.map { ($0.name, palace.branch) }
            })
            TestSupport.equal(actualAuxiliary, fixture.auxiliaryStars, "\(fixture.id) auxiliary stars by palace")
        }
        TestSupport.record(31, suite: "GoldenChartFixtureTests")
    }
}

private struct GoldenChart: Decodable {
    let id: String
    let year: Int
    let month: Int
    let day: Int
    let branch: Int
    let gender: Gender
    let mingGongBranch: Int
    let shenGongBranch: Int
    let wuxingJu: Int
    let ziweiPos: Int
    let majorStars: [Int: [String]]
    let auxiliaryStars: [String: Int]
}
