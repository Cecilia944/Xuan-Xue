import Foundation
import ZiweiCore

enum ChartRepositoryTests {
    static func run() {
        savesListsAndUpdatesRecords()
        deletesRecordAndInterpretationCache()
        enforcesThreeProfileLimitForFreeUsers()
        allowsUnlimitedProfilesForProUsers()
        preservesVersionAndSchoolSnapshots()
        keepsSensitiveBirthDataOutOfAuditEvents()
        TestSupport.record(20, suite: "ChartRepositoryTests")
    }

    private static func savesListsAndUpdatesRecords() {
        var repository = InMemoryChartRepository()
        let entitlement = DefaultEntitlementProvider(tier: .free)
        var record = makeRecord(index: 1)

        try! repository.save(record, entitlement: entitlement)
        TestSupport.equal(repository.list().count, 1, "save adds a record")
        TestSupport.equal(repository.list().first?.profile.name, "用户1", "list returns saved record")

        record.profile.name = "已编辑"
        try! repository.update(record)
        TestSupport.equal(repository.list().first?.profile.name, "已编辑", "update replaces record")
    }

    private static func deletesRecordAndInterpretationCache() {
        var repository = InMemoryChartRepository()
        let record = makeRecord(index: 1)
        try! repository.save(record, entitlement: DefaultEntitlementProvider(tier: .free))
        repository.cacheInterpretation("缓存内容", for: record.id)

        TestSupport.equal(repository.cachedInterpretation(for: record.id), "缓存内容", "cache is associated with record")
        try! repository.delete(id: record.id)
        TestSupport.equal(repository.list().isEmpty, true, "delete removes record")
        TestSupport.equal(repository.cachedInterpretation(for: record.id), nil, "delete removes related cache")
    }

    private static func enforcesThreeProfileLimitForFreeUsers() {
        var repository = InMemoryChartRepository()
        let free = DefaultEntitlementProvider(tier: .free)
        try! repository.save(makeRecord(index: 1), entitlement: free)
        try! repository.save(makeRecord(index: 2), entitlement: free)
        try! repository.save(makeRecord(index: 3), entitlement: free)

        TestSupport.equal(repository.list().count, FreeProfileLimit, "free tier stores three profiles")
        do {
            try repository.save(makeRecord(index: 4), entitlement: free)
            fatalError("FAIL fourth free profile should be rejected")
        } catch {
            TestSupport.equal(error as? ChartRepositoryError, .freeProfileLimitReached, "fourth free profile is rejected")
        }
    }

    private static func allowsUnlimitedProfilesForProUsers() {
        var repository = InMemoryChartRepository()
        let pro = DefaultEntitlementProvider(tier: .pro)
        for index in 1...4 {
            try! repository.save(makeRecord(index: index), entitlement: pro)
        }
        TestSupport.equal(repository.list().count, 4, "pro tier exceeds free profile limit")
    }

    private static func preservesVersionAndSchoolSnapshots() {
        var repository = InMemoryChartRepository()
        let record = makeRecord(index: 1)
        try! repository.save(record, entitlement: DefaultEntitlementProvider(tier: .free))
        let saved = repository.list()[0]

        TestSupport.equal(saved.algorithmVersion, "swift-core-1", "record snapshots algorithm version")
        TestSupport.equal(saved.contentVersion, "content-2026.10", "record snapshots content version")
        TestSupport.equal(saved.schoolConfiguration, .default, "record snapshots school configuration")
        TestSupport.equal(saved.chart, record.chart, "record snapshots generated chart")
    }

    private static func keepsSensitiveBirthDataOutOfAuditEvents() {
        var repository = InMemoryChartRepository()
        let record = makeRecord(index: 1)
        try! repository.save(record, entitlement: DefaultEntitlementProvider(tier: .free))
        let audit = repository.auditEvents.map(\.description).joined(separator: " ")

        TestSupport.equal(audit.contains("用户1"), false, "audit omits profile name")
        TestSupport.equal(audit.contains("北京"), false, "audit omits city")
        TestSupport.equal(audit.contains("116.4"), false, "audit omits longitude")
        TestSupport.equal(audit.contains("12:00"), false, "audit omits exact birth time")
    }

    private static func makeRecord(index: Int) -> ChartRecord {
        let id = UUID(uuidString: "00000000-0000-0000-0000-00000000000\(index)")!
        let profile = BirthProfile(
            id: id,
            name: "用户\(index)",
            gender: .female,
            date: .gregorian(year: 1992, month: 6, day: 15),
            time: .exact(hour: 12, minute: 0),
            location: BirthLocation(city: "北京", longitude: 116.4, utcOffsetMinutes: 480)
        )
        let confirmed = ConfirmedBirthTime(year: 1992, month: 6, day: 15, hour: 12, minute: 0, branch: 6)
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
