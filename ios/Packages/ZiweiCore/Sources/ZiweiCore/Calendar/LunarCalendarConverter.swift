import Foundation

public struct GregorianDate: Codable, Equatable, Sendable {
    public let year: Int
    public let month: Int
    public let day: Int

    public init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }
}

public enum LunarCalendarConverter {
    public static func toGregorian(
        year lunarYear: Int,
        month lunarMonth: Int,
        day lunarDay: Int,
        isLeapMonth: Bool
    ) -> GregorianDate? {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = TimeZone(secondsFromGMT: 0)!
        var chinese = Calendar(identifier: .chinese)
        chinese.timeZone = TimeZone(secondsFromGMT: 0)!

        guard var date = gregorian.date(from: DateComponents(year: lunarYear, month: 1, day: 1)),
              let end = gregorian.date(from: DateComponents(year: lunarYear + 1, month: 3, day: 1))
        else { return nil }

        while date < end {
            let lunar = chinese.dateComponents([.year, .month, .day], from: date)
            let solar = gregorian.dateComponents([.year, .month, .day], from: date)
            if let cycleYear = lunar.year,
               let month = lunar.month,
               let day = lunar.day,
               let solarYear = solar.year,
               let solarMonth = solar.month,
               let solarDay = solar.day {
                let resolvedLunarYear = [solarYear, solarYear - 1].first {
                    positiveModulo($0 - 1984, 60) + 1 == cycleYear
                }
                if resolvedLunarYear == lunarYear,
                   month == lunarMonth,
                   day == lunarDay,
                   (lunar.isLeapMonth ?? false) == isLeapMonth {
                    return GregorianDate(year: solarYear, month: solarMonth, day: solarDay)
                }
            }
            guard let next = gregorian.date(byAdding: .day, value: 1, to: date) else { return nil }
            date = next
        }
        return nil
    }

    private static func positiveModulo(_ value: Int, _ divisor: Int) -> Int {
        ((value % divisor) + divisor) % divisor
    }
}
