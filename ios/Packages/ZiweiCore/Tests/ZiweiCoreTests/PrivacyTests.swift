import Foundation
import ZiweiCore

enum PrivacyTests {
    static func run() {
        redactsSensitiveProfileDataByDefault()
        includesOnlyNicknameWhenExplicitlyRequested()
        keepsSharePolicyPrivateByDefault()
        TestSupport.record(13, suite: "PrivacyTests")
    }

    private static func redactsSensitiveProfileDataByDefault() {
        let record = makeRecord()
        let content = ChartShareContentBuilder.build(record: record, privacy: .default)
        let text = content.searchableText

        TestSupport.equal(content.nickname, nil, "default share omits nickname")
        TestSupport.equal(content.birthTimeLabel, "午时", "share uses branch instead of exact minute")
        TestSupport.equal(text.contains("敏感姓名"), false, "default share omits name")
        TestSupport.equal(text.contains("12:34"), false, "default share omits exact minute")
        TestSupport.equal(text.contains("北京"), false, "default share omits city")
        TestSupport.equal(text.contains("116.4"), false, "default share omits longitude")
        TestSupport.equal(text.contains("480"), false, "default share omits utc offset")
    }

    private static func includesOnlyNicknameWhenExplicitlyRequested() {
        let content = ChartShareContentBuilder.build(
            record: makeRecord(),
            privacy: SharePrivacyOptions(includeNickname: true)
        )

        TestSupport.equal(content.nickname, "敏感姓名", "explicit option includes nickname")
        TestSupport.equal(content.searchableText.contains("北京"), false, "nickname option still omits city")
        TestSupport.equal(content.searchableText.contains("12:34"), false, "nickname option still omits minute")
        TestSupport.equal(content.searchableText.contains("116.4"), false, "nickname option still omits coordinates")
    }

    private static func keepsSharePolicyPrivateByDefault() {
        TestSupport.equal(SharePrivacyOptions.default.includeNickname, false, "privacy defaults to no nickname")
        TestSupport.equal(ChartShareContentBuilder.requiresNetwork, false, "share preparation works offline")
    }

    private static func makeRecord() -> ChartRecord {
        let id = UUID(uuidString: "10000000-0000-0000-0000-000000000001")!
        let profile = BirthProfile(
            id: id,
            name: "敏感姓名",
            gender: .female,
            date: .gregorian(year: 1992, month: 6, day: 15),
            time: .exact(hour: 12, minute: 34),
            location: BirthLocation(city: "北京", longitude: 116.4, utcOffsetMinutes: 480)
        )
        let confirmed = ConfirmedBirthTime(year: 1992, month: 6, day: 15, hour: 12, minute: 31, branch: 6)
        let chart = try! ZiweiChartEngine.generate(ZiweiChartRequest(profile: profile, confirmedTime: confirmed))
        return ChartRecord(
            id: id,
            profile: profile,
            confirmedTime: confirmed,
            chart: chart,
            algorithmVersion: "swift-core-1",
            contentVersion: "content-2026.10",
            schoolConfiguration: .default
        )
    }
}
