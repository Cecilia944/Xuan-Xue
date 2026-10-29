import Foundation

public enum ZiweiChartEngine {
    public static func generate(_ request: ZiweiChartRequest) throws -> ZiweiChart {
        let time = request.confirmedTime
        let date: BirthDate = .gregorian(year: time.year, month: time.month, day: time.day)
        guard BirthDateValidator.validate(date) == .valid else { throw ZiweiChartError.invalidDate }
        guard (0...11).contains(time.branch) else { throw ZiweiChartError.invalidBranch }
        guard let lunar = lunarInfo(year: time.year, month: time.month, day: time.day) else {
            throw ZiweiChartError.lunarConversionFailed
        }

        let ming = modulo(2 + lunar.month - 1 - time.branch, 12)
        let shen = modulo(2 + lunar.month - 1 + time.branch, 12)
        let palaces = buildPalaces(ming: ming, shen: shen, yearStem: lunar.yearStem)
        let ju = wuxingJu(stem: palaces.first(where: { $0.branch == ming })!.stem, branch: ming)
        let names = [2: "水二局", 3: "木三局", 4: "金四局", 5: "土五局", 6: "火六局"]

        return ZiweiChart(
            lunarInfo: lunar,
            mingGongBranch: ming,
            shenGongBranch: shen,
            wuxingJu: ju,
            wuxingJuName: names[ju]!,
            palaces: palaces
        )
    }

    private static func lunarInfo(year: Int, month: Int, day: Int) -> ZiweiLunarInfo? {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = TimeZone(secondsFromGMT: 0)!
        guard let date = gregorian.date(from: DateComponents(year: year, month: month, day: day)) else { return nil }
        var chinese = Calendar(identifier: .chinese)
        chinese.timeZone = TimeZone(secondsFromGMT: 0)!
        let value = chinese.dateComponents([.year, .month, .day], from: date)
        guard let cycleYear = value.year, let lunarMonth = value.month, let lunarDay = value.day else { return nil }
        let candidates = [year, year - 1]
        guard let lunarYear = candidates.first(where: { modulo($0 - 1984, 60) + 1 == cycleYear }) else { return nil }
        return ZiweiLunarInfo(
            year: lunarYear,
            month: lunarMonth,
            day: lunarDay,
            isLeapMonth: value.isLeapMonth ?? false,
            yearStem: modulo(lunarYear - 4, 10),
            yearBranch: modulo(lunarYear - 4, 12)
        )
    }

    private static func buildPalaces(ming: Int, shen: Int, yearStem: Int) -> [ZiweiPalace] {
        let names = ["命宫", "兄弟", "夫妻", "子女", "财帛", "疾厄", "迁移", "仆役", "官禄", "田宅", "福德", "父母"]
        let tigerStem = ((yearStem % 5) * 2 + 2) % 10
        return (0..<12).map { branch in
            let nameOffset = modulo(ming - branch, 12)
            let stem = modulo(tigerStem + modulo(branch - 2, 12), 10)
            return ZiweiPalace(
                branch: branch,
                stem: stem,
                name: names[nameOffset],
                majorStars: [],
                isMingGong: branch == ming,
                isShenGong: branch == shen
            )
        }
    }

    private static func wuxingJu(stem: Int, branch: Int) -> Int {
        let index = (0..<60).first(where: { $0 % 10 == stem && $0 % 12 == branch })!
        let pairValues = [
            4, 6, 3, 5, 4, 6, 2, 5, 4, 3,
            2, 5, 6, 3, 2, 4, 6, 3, 5, 4,
            6, 2, 5, 4, 3, 2, 5, 6, 3, 2,
        ]
        return pairValues[index / 2]
    }

    private static func modulo(_ value: Int, _ base: Int) -> Int {
        ((value % base) + base) % base
    }
}
