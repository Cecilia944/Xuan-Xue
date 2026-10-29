import Foundation
import ZiweiCore

enum BirthFlowTests {
    static func run() {
        movesForwardAndBackAcrossFourSteps()
        blocksInvalidBirthDate()
        requiresBranchWhenBirthTimeIsUnknown()
        requiresExplicitConfirmationForCrossedTimeBoundary()
        keepsConfirmationVisibleWhenChartGenerationFails()
        TestSupport.record(16, suite: "BirthFlowTests")
    }

    private static func movesForwardAndBackAcrossFourSteps() {
        var flow = BirthFlowModel(profile: validProfile())

        TestSupport.equal(flow.step, .identity, "flow starts at identity")
        TestSupport.equal(flow.advance(), true, "identity advances")
        TestSupport.equal(flow.step, .birthData, "flow reaches birth data")
        TestSupport.equal(flow.advance(), true, "valid birth data advances")
        TestSupport.equal(flow.step, .timeCorrection, "flow reaches time correction")
        flow.goBack()
        TestSupport.equal(flow.step, .birthData, "back returns one step")
        flow.goBack()
        TestSupport.equal(flow.step, .identity, "back reaches first step")
    }

    private static func blocksInvalidBirthDate() {
        var profile = validProfile()
        profile.date = .gregorian(year: 2025, month: 2, day: 30)
        var flow = BirthFlowModel(profile: profile)

        _ = flow.advance()
        TestSupport.equal(flow.advance(), false, "invalid date is blocked")
        TestSupport.equal(flow.step, .birthData, "invalid date stays on birth data")
        TestSupport.equal(flow.issue, .invalidDate, "invalid date is explained")
    }

    private static func requiresBranchWhenBirthTimeIsUnknown() {
        var profile = validProfile()
        profile.time = .unknown
        var flow = BirthFlowModel(profile: profile)

        _ = flow.advance()
        _ = flow.advance()
        TestSupport.equal(flow.advance(), false, "unknown time cannot skip branch selection")
        TestSupport.equal(flow.issue, .unknownTimeRequiresBranch, "unknown time asks for branch")
        flow.selectUnknownTimeBranch(6)
        TestSupport.equal(flow.advance(), true, "selected branch can be confirmed")
        TestSupport.equal(flow.step, .confirmation, "unknown time reaches confirmation")
    }

    private static func requiresExplicitConfirmationForCrossedTimeBoundary() {
        var flow = BirthFlowModel(profile: crossingProfile())

        _ = flow.advance()
        _ = flow.advance()
        TestSupport.equal(flow.advance(), false, "crossed boundary cannot be accepted silently")
        TestSupport.equal(flow.issue, .timeCorrectionConfirmationRequired, "crossed boundary asks for confirmation")
        flow.confirmTimeCorrection()
        TestSupport.equal(flow.advance(), true, "explicit confirmation advances")
        TestSupport.equal(flow.step, .confirmation, "confirmed correction reaches confirmation")
    }

    private static func keepsConfirmationVisibleWhenChartGenerationFails() {
        var flow = BirthFlowModel(
            profile: validProfile(),
            chartGenerator: { _ in throw StubGenerationError.failed }
        )

        _ = flow.advance()
        _ = flow.advance()
        _ = flow.advance()
        TestSupport.equal(flow.generateDraft(), nil, "generation failure produces no draft")
        TestSupport.equal(flow.step, .confirmation, "generation failure stays on confirmation")
        TestSupport.equal(flow.issue, .chartGenerationFailed, "generation failure is explained")
    }

    private static func validProfile() -> BirthProfile {
        BirthProfile(
            name: "测试用户",
            gender: .female,
            date: .gregorian(year: 1992, month: 6, day: 15),
            time: .exact(hour: 12, minute: 0),
            location: BirthLocation(city: "北京", longitude: 116.4, utcOffsetMinutes: 480)
        )
    }

    private static func crossingProfile() -> BirthProfile {
        BirthProfile(
            name: "跨界样例",
            gender: .male,
            date: .gregorian(year: 1990, month: 6, day: 15),
            time: .exact(hour: 23, minute: 59),
            location: BirthLocation(city: "东经135度", longitude: 135, utcOffsetMinutes: 480)
        )
    }

    private enum StubGenerationError: Error {
        case failed
    }
}
