import ZiweiCore

enum LunarCalendarConverterTests {
    static func run() {
        TestSupport.equal(
            LunarCalendarConverter.toGregorian(year: 1990, month: 1, day: 1, isLeapMonth: false),
            GregorianDate(year: 1990, month: 1, day: 27),
            "converts 1990 lunar new year"
        )
        TestSupport.equal(
            LunarCalendarConverter.toGregorian(year: 2000, month: 1, day: 1, isLeapMonth: false),
            GregorianDate(year: 2000, month: 2, day: 5),
            "converts 2000 lunar new year"
        )
        TestSupport.record(2, suite: "LunarCalendarConverterTests")
    }
}
