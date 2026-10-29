import Foundation

public enum TimeCorrectionError: Error, Equatable {
    case gregorianDateRequired
    case exactTimeRequired
    case locationRequired
    case invalidDate
}

public struct TimeCorrectionProposal: Equatable, Sendable {
    public let longitudeCorrectionMinutes: Double
    public let equationOfTimeMinutes: Double
    public let correctedHour: Int
    public let correctedMinute: Int
    public let correctedSecond: Int
    public let dayOffset: Int
    public let branch: Int
    public let chinaDSTDetected: Bool
    public let appliedDSTAdjustmentMinutes: Int
    public let requiresConfirmation: Bool
}

public struct ConfirmedBirthTime: Equatable, Sendable {
    public let year: Int
    public let month: Int
    public let day: Int
    public let hour: Int
    public let minute: Int
    public let branch: Int
}

public enum TrueSolarTimeCalculator {
    public static func calculate(_ profile: BirthProfile) throws -> TimeCorrectionProposal {
        guard case let .gregorian(year, month, day) = profile.date else {
            throw TimeCorrectionError.gregorianDateRequired
        }
        guard BirthDateValidator.validate(profile.date) == .valid else {
            throw TimeCorrectionError.invalidDate
        }
        guard case let .exact(hour, minute) = profile.time else {
            throw TimeCorrectionError.exactTimeRequired
        }
        guard let location = profile.location else {
            throw TimeCorrectionError.locationRequired
        }

        let meridian = Double(location.utcOffsetMinutes) / 4
        let longitudeCorrection = (location.longitude - meridian) * 4
        let eot = equationOfTime(year: year, month: month, day: day, hour: hour, minute: minute)
        let rawMinutes = Double(hour * 60 + minute) + longitudeCorrection + eot
        let roundedSeconds = Int((rawMinutes * 60).rounded())
        let dayOffset = Int(floor(Double(roundedSeconds) / 86_400))
        let secondOfDay = positiveModulo(roundedSeconds, 86_400)
        let correctedHour = secondOfDay / 3_600
        let correctedMinute = (secondOfDay % 3_600) / 60
        let correctedSecond = secondOfDay % 60
        let normalizedMinutes = Double(secondOfDay) / 60
        let correctedBranch = branch(for: normalizedMinutes)
        let originalBranch = branch(for: Double(hour * 60 + minute))
        let dstDetected = location.utcOffsetMinutes == 480
            && ChinaDST.contains(year: year, month: month, day: day)

        return TimeCorrectionProposal(
            longitudeCorrectionMinutes: longitudeCorrection,
            equationOfTimeMinutes: eot,
            correctedHour: correctedHour,
            correctedMinute: correctedMinute,
            correctedSecond: correctedSecond,
            dayOffset: dayOffset,
            branch: correctedBranch,
            chinaDSTDetected: dstDetected,
            appliedDSTAdjustmentMinutes: 0,
            requiresConfirmation: dayOffset != 0 || correctedBranch != originalBranch || dstDetected
        )
    }

    private static func branch(for minutes: Double) -> Int {
        if minutes >= 1_380 || minutes < 60 { return 0 }
        return Int(floor((minutes - 60) / 120)) + 1
    }

    private static func equationOfTime(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> Double {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let date = calendar.date(from: DateComponents(year: year, month: month, day: day))!
        let ordinal = calendar.ordinality(of: .day, in: .year, for: date)!
        let days = calendar.range(of: .day, in: .year, for: date)!.count
        let fractionalHour = Double(hour) + Double(minute) / 60
        let gamma = (2 * Double.pi / Double(days))
            * (Double(ordinal - 1) + (fractionalHour - 12) / 24)
        return 229.18 * (
            0.000075
                + 0.001868 * cos(gamma)
                - 0.032077 * sin(gamma)
                - 0.014615 * cos(2 * gamma)
                - 0.040849 * sin(2 * gamma)
        )
    }

    private static func positiveModulo(_ value: Int, _ divisor: Int) -> Int {
        ((value % divisor) + divisor) % divisor
    }
}
