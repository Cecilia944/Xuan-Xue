import Foundation

public enum BirthValidationError: String, Codable, Equatable, Sendable {
    case yearOutOfRange
    case invalidMonth
    case invalidDay
    case leapMonthMismatch
}

public enum BirthValidationResult: Codable, Equatable, Sendable {
    case valid
    case invalid(BirthValidationError)
}

public enum BirthDateValidator {
    public static let supportedYears = 1900...2050

    public static func validate(_ date: BirthDate) -> BirthValidationResult {
        switch date {
        case let .gregorian(year, month, day):
            return validateGregorian(year: year, month: month, day: day)
        case let .lunar(year, month, day, isLeapMonth):
            return validateLunar(
                year: year,
                month: month,
                day: day,
                isLeapMonth: isLeapMonth
            )
        }
    }

    private static func validateGregorian(year: Int, month: Int, day: Int) -> BirthValidationResult {
        guard supportedYears.contains(year) else { return .invalid(.yearOutOfRange) }
        guard (1...12).contains(month) else { return .invalid(.invalidMonth) }

        var calendar = Foundation.Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let components = DateComponents(
            calendar: calendar,
            timeZone: calendar.timeZone,
            year: year,
            month: month,
            day: day
        )
        guard let value = calendar.date(from: components) else { return .invalid(.invalidDay) }
        let resolved = calendar.dateComponents([.year, .month, .day], from: value)
        guard resolved.year == year, resolved.month == month, resolved.day == day else {
            return .invalid(.invalidDay)
        }
        return .valid
    }

    private static func validateLunar(
        year: Int,
        month: Int,
        day: Int,
        isLeapMonth: Bool
    ) -> BirthValidationResult {
        guard supportedYears.contains(year) else { return .invalid(.yearOutOfRange) }
        guard (1...12).contains(month) else { return .invalid(.invalidMonth) }
        guard (1...30).contains(day) else { return .invalid(.invalidDay) }
        if isLeapMonth, leapMonths[year] != month {
            return .invalid(.leapMonthMismatch)
        }
        return .valid
    }

    private static let leapMonths: [Int: Int] = [
        1900: 8, 1903: 5, 1906: 4, 1909: 2, 1911: 6, 1914: 5,
        1917: 2, 1919: 7, 1922: 5, 1925: 4, 1928: 2, 1930: 6,
        1933: 5, 1936: 3, 1938: 7, 1941: 6, 1944: 4, 1947: 2,
        1949: 7, 1952: 5, 1955: 3, 1957: 8, 1960: 6, 1963: 4,
        1966: 3, 1968: 7, 1971: 5, 1974: 4, 1976: 8, 1979: 6,
        1982: 4, 1984: 10, 1987: 6, 1990: 5, 1993: 3, 1995: 8,
        1998: 5, 2001: 4, 2004: 2, 2006: 7, 2009: 5, 2012: 4,
        2014: 9, 2017: 6, 2020: 4, 2023: 2, 2025: 6, 2028: 5,
        2031: 3, 2033: 11, 2036: 6, 2039: 5, 2042: 2, 2044: 7,
        2047: 5, 2050: 3,
    ]
}
