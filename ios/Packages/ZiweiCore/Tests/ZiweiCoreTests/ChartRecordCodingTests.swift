import Foundation
import ZiweiCore

enum ChartRecordCodingTests {
    static func run() {
        let record = makeRecord()
        let data = try! JSONEncoder().encode(record)
        let decoded = try! JSONDecoder().decode(ChartRecord.self, from: data)

        TestSupport.equal(decoded, record, "chart record survives persistence round trip")
        TestSupport.equal(decoded.confirmedTime.minute, 31, "persistence keeps confirmed minute")
        TestSupport.equal(decoded.schoolConfiguration, .default, "persistence keeps school snapshot")
        TestSupport.record(3, suite: "ChartRecordCodingTests")
    }

    private static func makeRecord() -> ChartRecord {
        let id = UUID(uuidString: "20000000-0000-0000-0000-000000000001")!
        let profile = BirthProfile(
            id: id,
            name: "持久化样例",
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
