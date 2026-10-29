import ZiweiCore

enum BirthDateValidatorTests {
    static func run() {
        TestSupport.equal(
            BirthDateValidator.validate(.gregorian(year: 1990, month: 6, day: 18)),
            .valid,
            "accepts ordinary Gregorian date"
        )
        TestSupport.equal(
            BirthDateValidator.validate(.gregorian(year: 2000, month: 2, day: 29)),
            .valid,
            "accepts leap day"
        )
        TestSupport.equal(
            BirthDateValidator.validate(.gregorian(year: 2001, month: 2, day: 29)),
            .invalid(.invalidDay),
            "rejects non-leap February 29"
        )
        TestSupport.equal(
            BirthDateValidator.validate(.gregorian(year: 2026, month: 2, day: 30)),
            .invalid(.invalidDay),
            "rejects February 30"
        )
        TestSupport.equal(
            BirthDateValidator.validate(.lunar(year: 2020, month: 4, day: 1, isLeapMonth: true)),
            .valid,
            "accepts real leap lunar month"
        )
        TestSupport.equal(
            BirthDateValidator.validate(.lunar(year: 2021, month: 4, day: 1, isLeapMonth: true)),
            .invalid(.leapMonthMismatch),
            "rejects nonexistent leap lunar month"
        )
        TestSupport.equal(
            BirthDateValidator.validate(.gregorian(year: 1900, month: 1, day: 1)),
            .valid,
            "accepts lower year boundary"
        )
        TestSupport.equal(
            BirthDateValidator.validate(.lunar(year: 2050, month: 12, day: 1, isLeapMonth: false)),
            .valid,
            "accepts upper year boundary"
        )
        TestSupport.equal(
            BirthDateValidator.validate(.gregorian(year: 1899, month: 12, day: 31)),
            .invalid(.yearOutOfRange),
            "rejects below lower year boundary"
        )
        TestSupport.equal(
            BirthTimePrecision.unknown,
            .unknown,
            "unknown birth time is explicit"
        )
        TestSupport.record(10, suite: "BirthDateValidatorTests")
    }
}
