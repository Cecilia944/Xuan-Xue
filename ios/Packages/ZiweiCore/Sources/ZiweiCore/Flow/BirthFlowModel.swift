import Foundation

public enum BirthFlowStep: Int, CaseIterable, Sendable {
    case identity
    case birthData
    case timeCorrection
    case confirmation
}

public enum BirthFlowIssue: Equatable, Sendable {
    case missingName
    case invalidDate
    case timeCorrectionFailed
    case unknownTimeRequiresBranch
    case timeCorrectionConfirmationRequired
    case chartGenerationFailed
}

public struct ZiweiChartDraft: Equatable, Sendable {
    public let profile: BirthProfile
    public let confirmedTime: ConfirmedBirthTime
    public let chart: ZiweiChart
}

public struct BirthFlowModel {
    public typealias ChartGenerator = (ZiweiChartRequest) throws -> ZiweiChart

    public private(set) var step: BirthFlowStep = .identity
    public var profile: BirthProfile
    public private(set) var issue: BirthFlowIssue?
    public private(set) var correctionProposal: TimeCorrectionProposal?
    public private(set) var selectedUnknownTimeBranch: Int?
    public private(set) var hasConfirmedTimeCorrection = false
    public private(set) var confirmedTime: ConfirmedBirthTime?

    private let chartGenerator: ChartGenerator

    public init(
        profile: BirthProfile,
        chartGenerator: @escaping ChartGenerator = ZiweiChartEngine.generate
    ) {
        self.profile = profile
        self.chartGenerator = chartGenerator
    }

    @discardableResult
    public mutating func advance() -> Bool {
        issue = nil

        switch step {
        case .identity:
            guard !profile.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                issue = .missingName
                return false
            }
            step = .birthData
            return true

        case .birthData:
            guard BirthDateValidator.validate(profile.date) == .valid else {
                issue = .invalidDate
                return false
            }
            if case .exact = profile.time {
                do {
                    correctionProposal = try TrueSolarTimeCalculator.calculate(correctionProfile())
                } catch {
                    issue = .timeCorrectionFailed
                    return false
                }
            } else {
                correctionProposal = nil
            }
            hasConfirmedTimeCorrection = false
            confirmedTime = nil
            step = .timeCorrection
            return true

        case .timeCorrection:
            guard let acceptedTime = makeConfirmedTime() else { return false }
            confirmedTime = acceptedTime
            step = .confirmation
            return true

        case .confirmation:
            return false
        }
    }

    public mutating func goBack() {
        issue = nil
        guard let previous = BirthFlowStep(rawValue: step.rawValue - 1) else { return }
        step = previous
    }

    public mutating func selectUnknownTimeBranch(_ branch: Int) {
        selectedUnknownTimeBranch = (0..<12).contains(branch) ? branch : nil
        issue = nil
    }

    public mutating func confirmTimeCorrection() {
        hasConfirmedTimeCorrection = true
        issue = nil
    }

    public mutating func generateDraft(
        schoolConfiguration: SchoolConfiguration = .default
    ) -> ZiweiChartDraft? {
        issue = nil
        guard step == .confirmation, let confirmedTime else { return nil }

        do {
            let chart = try chartGenerator(
                ZiweiChartRequest(
                    profile: profile,
                    confirmedTime: confirmedTime,
                    schoolConfiguration: schoolConfiguration
                )
            )
            return ZiweiChartDraft(profile: profile, confirmedTime: confirmedTime, chart: chart)
        } catch {
            issue = .chartGenerationFailed
            return nil
        }
    }

    private mutating func makeConfirmedTime() -> ConfirmedBirthTime? {
        switch profile.time {
        case .exact:
            guard let proposal = correctionProposal else {
                issue = .timeCorrectionFailed
                return nil
            }
            guard !proposal.requiresConfirmation || hasConfirmedTimeCorrection else {
                issue = .timeCorrectionConfirmationRequired
                return nil
            }
            return confirmedTime(from: proposal)

        case let .approximate(branch):
            guard (0..<12).contains(branch) else {
                issue = .unknownTimeRequiresBranch
                return nil
            }
            return representativeTime(for: branch)

        case .unknown:
            guard let branch = selectedUnknownTimeBranch else {
                issue = .unknownTimeRequiresBranch
                return nil
            }
            return representativeTime(for: branch)
        }
    }

    private func confirmedTime(from proposal: TimeCorrectionProposal) -> ConfirmedBirthTime? {
        guard let source = gregorianDate() else { return nil }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        guard let date = calendar.date(from: DateComponents(year: source.year, month: source.month, day: source.day)),
              let adjusted = calendar.date(byAdding: .day, value: proposal.dayOffset, to: date)
        else { return nil }
        let parts = calendar.dateComponents([.year, .month, .day], from: adjusted)
        guard let adjustedYear = parts.year, let adjustedMonth = parts.month, let adjustedDay = parts.day else {
            return nil
        }
        return ConfirmedBirthTime(
            year: adjustedYear,
            month: adjustedMonth,
            day: adjustedDay,
            hour: proposal.correctedHour,
            minute: proposal.correctedMinute,
            branch: proposal.branch
        )
    }

    private func representativeTime(for branch: Int) -> ConfirmedBirthTime? {
        guard let date = gregorianDate() else { return nil }
        return ConfirmedBirthTime(
            year: date.year,
            month: date.month,
            day: date.day,
            hour: branch == 0 ? 0 : branch * 2,
            minute: 0,
            branch: branch
        )
    }

    private func correctionProfile() throws -> BirthProfile {
        guard let date = gregorianDate() else { throw TimeCorrectionError.invalidDate }
        var converted = profile
        converted.date = .gregorian(year: date.year, month: date.month, day: date.day)
        return converted
    }

    private func gregorianDate() -> GregorianDate? {
        switch profile.date {
        case let .gregorian(year, month, day):
            return GregorianDate(year: year, month: month, day: day)
        case let .lunar(year, month, day, isLeapMonth):
            return LunarCalendarConverter.toGregorian(
                year: year,
                month: month,
                day: day,
                isLeapMonth: isLeapMonth
            )
        }
    }
}
