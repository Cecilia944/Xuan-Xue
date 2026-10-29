import Foundation
import ZiweiCore

enum TrueSolarTimeTests {
    static func run() {
        let chengdu = profile(
            date: .gregorian(year: 1990, month: 6, day: 15),
            hour: 8,
            minute: 30,
            longitude: 104.0665,
            offset: 480
        )
        let local = try! TrueSolarTimeCalculator.calculate(chengdu)
        TestSupport.equal(local.correctedHour, 7, "applies longitude and equation-of-time hour")
        TestSupport.equal(local.correctedMinute, 26, "applies longitude and equation-of-time minute")
        TestSupport.equal(local.correctedSecond, 16, "rounds correction to nearest second")
        TestSupport.equal(local.branch, 4, "maps corrected time to chen branch")

        let newYork = profile(
            date: .gregorian(year: 1990, month: 6, day: 15),
            hour: 8,
            minute: 30,
            longitude: -74,
            offset: -300
        )
        let overseas = try! TrueSolarTimeCalculator.calculate(newYork)
        TestSupport.equal(overseas.longitudeCorrectionMinutes, 4, "uses overseas standard meridian")
        TestSupport.equal(overseas.correctedMinute, 34, "corrects overseas clock")

        let crossDay = profile(
            date: .gregorian(year: 1990, month: 6, day: 15),
            hour: 23,
            minute: 59,
            longitude: 135,
            offset: 480
        )
        let crossed = try! TrueSolarTimeCalculator.calculate(crossDay)
        TestSupport.equal(crossed.dayOffset, 1, "reports next-day correction")
        TestSupport.equal(crossed.branch, 0, "maps corrected late time to zi branch")
        TestSupport.equal(crossed.requiresConfirmation, true, "requires confirmation across day")

        TestSupport.equal(ChinaDST.contains(year: 1988, month: 4, day: 10), true, "uses 1988 golden DST start")
        TestSupport.equal(ChinaDST.contains(year: 1988, month: 4, day: 9), false, "excludes day before DST start")
        TestSupport.equal(ChinaDST.contains(year: 1992, month: 6, day: 1), false, "does not extend DST into 1992")

        let dst = profile(
            date: .gregorian(year: 1990, month: 6, day: 15),
            hour: 8,
            minute: 30,
            longitude: 120,
            offset: 480
        )
        let dstProposal = try! TrueSolarTimeCalculator.calculate(dst)
        TestSupport.equal(dstProposal.chinaDSTDetected, true, "detects historical China DST")
        TestSupport.equal(dstProposal.requiresConfirmation, true, "DST only prompts and requires confirmation")
        TestSupport.equal(dstProposal.appliedDSTAdjustmentMinutes, 0, "never silently subtracts DST")

        TestSupport.record(15, suite: "TrueSolarTimeTests")
    }

    private static func profile(
        date: BirthDate,
        hour: Int,
        minute: Int,
        longitude: Double,
        offset: Int
    ) -> BirthProfile {
        BirthProfile(
            name: "fixture",
            gender: .male,
            date: date,
            time: .exact(hour: hour, minute: minute),
            location: BirthLocation(city: "fixture", longitude: longitude, utcOffsetMinutes: offset)
        )
    }
}
