public enum ChinaDST {
    private struct Span {
        let year: Int
        let startMonth: Int
        let startDay: Int
        let endMonth: Int
        let endDay: Int
    }

    public static func contains(year: Int, month: Int, day: Int) -> Bool {
        guard let span = spans.first(where: { $0.year == year }) else { return false }
        if month > span.startMonth && month < span.endMonth { return true }
        if month == span.startMonth { return day >= span.startDay }
        if month == span.endMonth { return day <= span.endDay }
        return false
    }

    private static let spans = [
        Span(year: 1935, startMonth: 5, startDay: 1, endMonth: 9, endDay: 30),
        Span(year: 1936, startMonth: 5, startDay: 1, endMonth: 9, endDay: 30),
        Span(year: 1937, startMonth: 5, startDay: 1, endMonth: 9, endDay: 30),
        Span(year: 1938, startMonth: 5, startDay: 1, endMonth: 9, endDay: 30),
        Span(year: 1939, startMonth: 5, startDay: 1, endMonth: 9, endDay: 30),
        Span(year: 1940, startMonth: 5, startDay: 1, endMonth: 9, endDay: 30),
        Span(year: 1941, startMonth: 5, startDay: 1, endMonth: 9, endDay: 30),
        Span(year: 1942, startMonth: 5, startDay: 1, endMonth: 9, endDay: 30),
        Span(year: 1943, startMonth: 5, startDay: 1, endMonth: 9, endDay: 30),
        Span(year: 1944, startMonth: 5, startDay: 1, endMonth: 9, endDay: 30),
        Span(year: 1945, startMonth: 5, startDay: 1, endMonth: 9, endDay: 30),
        Span(year: 1946, startMonth: 5, startDay: 1, endMonth: 9, endDay: 30),
        Span(year: 1947, startMonth: 5, startDay: 1, endMonth: 9, endDay: 30),
        Span(year: 1948, startMonth: 5, startDay: 1, endMonth: 9, endDay: 30),
        Span(year: 1949, startMonth: 5, startDay: 1, endMonth: 9, endDay: 30),
        Span(year: 1950, startMonth: 5, startDay: 1, endMonth: 9, endDay: 30),
        Span(year: 1951, startMonth: 5, startDay: 1, endMonth: 9, endDay: 30),
        Span(year: 1952, startMonth: 3, startDay: 1, endMonth: 10, endDay: 31),
        Span(year: 1953, startMonth: 4, startDay: 1, endMonth: 10, endDay: 31),
        Span(year: 1954, startMonth: 4, startDay: 1, endMonth: 10, endDay: 31),
        Span(year: 1955, startMonth: 5, startDay: 1, endMonth: 9, endDay: 30),
        Span(year: 1956, startMonth: 5, startDay: 1, endMonth: 9, endDay: 30),
        Span(year: 1957, startMonth: 4, startDay: 1, endMonth: 9, endDay: 30),
        Span(year: 1958, startMonth: 4, startDay: 1, endMonth: 9, endDay: 30),
        Span(year: 1959, startMonth: 4, startDay: 1, endMonth: 9, endDay: 30),
        Span(year: 1960, startMonth: 6, startDay: 1, endMonth: 9, endDay: 30),
        Span(year: 1961, startMonth: 6, startDay: 1, endMonth: 9, endDay: 30),
        Span(year: 1974, startMonth: 4, startDay: 1, endMonth: 10, endDay: 31),
        Span(year: 1975, startMonth: 4, startDay: 1, endMonth: 10, endDay: 31),
        Span(year: 1979, startMonth: 7, startDay: 1, endMonth: 9, endDay: 30),
        Span(year: 1986, startMonth: 5, startDay: 4, endMonth: 9, endDay: 14),
        Span(year: 1987, startMonth: 4, startDay: 12, endMonth: 9, endDay: 13),
        Span(year: 1988, startMonth: 4, startDay: 10, endMonth: 9, endDay: 11),
        Span(year: 1989, startMonth: 4, startDay: 16, endMonth: 9, endDay: 17),
        Span(year: 1990, startMonth: 4, startDay: 15, endMonth: 9, endDay: 16),
        Span(year: 1991, startMonth: 4, startDay: 14, endMonth: 9, endDay: 15),
    ]
}
