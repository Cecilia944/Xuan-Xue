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
        var palaces = buildPalaces(ming: ming, shen: shen, yearStem: lunar.yearStem)
        let ju = wuxingJu(stem: palaces.first(where: { $0.branch == ming })!.stem, branch: ming)
        let ziweiPos = placeMajorStars(in: &palaces, lunarDay: lunar.day, bureau: ju, yearStem: lunar.yearStem)
        placeAuxiliaryStars(
            in: &palaces,
            lunarMonth: lunar.month,
            hourBranch: time.branch,
            yearStem: lunar.yearStem,
            yearBranch: lunar.yearBranch
        )
        applyDecades(in: &palaces, ming: ming, bureau: ju, yearStem: lunar.yearStem, gender: request.profile.gender)
        applyBorrowedPalaces(in: &palaces)
        let names = [2: "水二局", 3: "木三局", 4: "金四局", 5: "土五局", 6: "火六局"]
        let mingZhuNames = ["贪狼", "巨门", "禄存", "文曲", "廉贞", "武曲", "破军", "武曲", "廉贞", "文曲", "禄存", "巨门"]
        let shenZhuNames = ["火星", "天相", "天梁", "天同", "文昌", "天机", "火星", "天相", "天梁", "天同", "文昌", "天机"]
        let yinYang = lunar.yearStem.isMultiple(of: 2) ? "阳" : "阴"
        let genderName = request.profile.gender == .male ? "男" : "女"

        return ZiweiChart(
            lunarInfo: lunar,
            mingGongBranch: ming,
            shenGongBranch: shen,
            wuxingJu: ju,
            wuxingJuName: names[ju]!,
            ziweiPos: ziweiPos,
            mingZhu: mingZhuNames[ming],
            shenZhu: shenZhuNames[lunar.yearBranch],
            yinYangGender: yinYang + genderName,
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

    private static func placeMajorStars(
        in palaces: inout [ZiweiPalace],
        lunarDay: Int,
        bureau: Int,
        yearStem: Int
    ) -> Int {
        let adjustment = (bureau - lunarDay % bureau) % bureau
        let quotient = (lunarDay + adjustment) / bureau
        let step = adjustment.isMultiple(of: 2) ? quotient + adjustment : quotient - adjustment
        let ziwei = modulo(2 + step - 1, 12)
        let tianfuPairs = [4, 3, 2, 1, 0, 11, 10, 9, 8, 7, 6, 5]
        let tianfu = tianfuPairs[ziwei]
        let definitions: [(Int, String, Int)] = [
            (1, "紫微", ziwei), (2, "天机", modulo(ziwei - 1, 12)),
            (3, "太阳", modulo(ziwei - 3, 12)), (4, "武曲", modulo(ziwei - 4, 12)),
            (5, "天同", modulo(ziwei - 5, 12)), (6, "廉贞", modulo(ziwei - 8, 12)),
            (7, "天府", tianfu), (8, "太阴", modulo(tianfu + 1, 12)),
            (9, "贪狼", modulo(tianfu + 2, 12)), (10, "巨门", modulo(tianfu + 3, 12)),
            (11, "天相", modulo(tianfu + 4, 12)), (12, "天梁", modulo(tianfu + 5, 12)),
            (13, "七杀", modulo(tianfu + 6, 12)), (14, "破军", modulo(tianfu + 10, 12)),
        ]
        let transformations = siHuaByStarID[yearStem]
        for (id, name, branch) in definitions {
            let star = ZiweiStar(
                name: name,
                brightness: brightness(starID: id, branch: branch),
                siHua: transformations.first(where: { $0.value == id })?.key
            )
            palaces[branch].majorStars.append(star)
        }
        return ziwei
    }

    private static let siHuaByStarID: [[SiHua: Int]] = [
        [.lu: 6, .quan: 14, .ke: 4, .ji: 3],
        [.lu: 2, .quan: 12, .ke: 1, .ji: 8],
        [.lu: 5, .quan: 2, .ke: 15, .ji: 6],
        [.lu: 8, .quan: 5, .ke: 2, .ji: 10],
        [.lu: 9, .quan: 8, .ke: 18, .ji: 2],
        [.lu: 4, .quan: 9, .ke: 12, .ji: 16],
        [.lu: 3, .quan: 4, .ke: 8, .ji: 5],
        [.lu: 10, .quan: 3, .ke: 16, .ji: 15],
        [.lu: 12, .quan: 1, .ke: 17, .ji: 4],
        [.lu: 14, .quan: 10, .ke: 8, .ji: 9],
    ]

    private static func brightness(starID: Int, branch: Int) -> StarBrightness? {
        let table = [
            [0,0,0,0,0,0,0,0,0,0,0,0,0],
            [0,5,1,2,2,3,2,1,1,2,2,3,2], [0,1,7,3,2,4,5,1,7,3,2,4,5],
            [0,7,6,2,1,2,2,2,3,3,5,6,7], [0,2,1,3,4,1,5,2,1,3,4,1,5],
            [0,2,6,4,5,5,1,7,6,2,5,5,1], [0,5,4,1,5,4,7,5,4,1,5,4,7],
            [0,1,1,1,3,1,3,2,1,3,2,1,3], [0,1,1,2,7,7,7,6,6,4,2,2,1],
            [0,2,1,5,4,1,7,2,1,5,4,1,7], [0,2,6,1,1,7,2,2,6,1,1,7,2],
            [0,1,1,1,7,3,3,1,3,1,7,3,3], [0,1,2,1,1,1,3,1,2,7,3,1,7],
            [0,2,1,1,2,1,5,2,1,1,2,1,5], [0,1,2,3,7,2,5,1,2,3,7,2,5],
            [0,3,1,7,4,3,1,7,4,3,1,7,4], [0,3,1,5,2,3,1,7,2,3,1,7,2],
            [0,2,1,1,7,1,5,2,1,5,7,1,6], [0,1,1,2,7,1,5,2,1,6,7,1,5],
            [0,2,2,0,1,0,0,1,0,0,0,0,2], [0,0,0,2,0,0,2,0,2,1,1,0,0],
            [0,1,0,1,1,0,1,1,0,1,1,0,1], [0,0,0,2,0,0,5,0,0,2,0,0,5],
            [0,7,3,1,4,7,3,1,4,7,3,1,4], [0,7,3,1,4,7,3,1,4,7,3,1,4],
            [0,7,1,0,7,1,0,7,1,0,7,1,0], [0,0,1,7,0,1,7,0,1,7,0,1,7],
            [0,5,7,7,5,7,1,1,5,1,1,7,7], [0,7,7,5,5,7,6,1,5,1,5,5,7],
        ]
        let value = table[starID][branch + 1]
        return [1: .miao, 2: .wang, 3: .de, 4: .li, 5: .ping, 6: .bu, 7: .luo][value]
    }

    private static func placeAuxiliaryStars(
        in palaces: inout [ZiweiPalace],
        lunarMonth: Int,
        hourBranch: Int,
        yearStem: Int,
        yearBranch: Int
    ) {
        let kuiYue = [
            (1,7), (0,8), (11,9), (11,9), (1,7),
            (0,8), (1,7), (2,6), (3,5), (3,5),
        ][yearStem]
        let lu = [2,3,5,6,5,6,8,9,11,0][yearStem]
        let ma: Int
        switch yearBranch {
        case 2,6,10: ma = 8
        case 8,0,4: ma = 2
        case 5,9,1: ma = 11
        default: ma = 5
        }
        let bases: (Int, Int)
        switch yearBranch {
        case 2,6,10: bases = (1,3)
        case 8,0,4: bases = (2,10)
        case 5,9,1: bases = (3,10)
        default: bases = (9,10)
        }
        let stars: [(Int, String, Int)] = [
            (15, "文昌", modulo(10 - hourBranch, 12)),
            (16, "文曲", modulo(4 + hourBranch, 12)),
            (17, "左辅", modulo(3 + lunarMonth, 12)),
            (18, "右弼", modulo(11 - lunarMonth, 12)),
            (19, "天魁", kuiYue.0), (20, "天钺", kuiYue.1),
            (21, "禄存", lu), (22, "天马", ma),
            (25, "擎羊", modulo(lu + 1, 12)), (26, "陀罗", modulo(lu - 1, 12)),
            (23, "火星", modulo(bases.0 + hourBranch, 12)),
            (24, "铃星", modulo(bases.1 + hourBranch, 12)),
            (27, "地空", modulo(11 - hourBranch, 12)),
            (28, "地劫", modulo(11 + hourBranch, 12)),
        ]
        let transformations = siHuaByStarID[yearStem]
        for (id, name, branch) in stars {
            palaces[branch].auxiliaryStars.append(
                ZiweiStar(
                    name: name,
                    brightness: brightness(starID: id, branch: branch),
                    siHua: transformations.first(where: { $0.value == id })?.key
                )
            )
        }
    }

    private static func applyDecades(
        in palaces: inout [ZiweiPalace],
        ming: Int,
        bureau: Int,
        yearStem: Int,
        gender: Gender
    ) {
        let isYang = yearStem.isMultiple(of: 2)
        let forward = (isYang && gender == .male) || (!isYang && gender == .female)
        for index in palaces.indices {
            let distance = forward
                ? modulo(palaces[index].branch - ming, 12)
                : modulo(ming - palaces[index].branch, 12)
            let start = bureau + distance * 10
            palaces[index].daXianAge = AgeRange(start: start, end: start + 9)
        }
    }

    private static func applyBorrowedPalaces(in palaces: inout [ZiweiPalace]) {
        for index in palaces.indices where palaces[index].majorStars.isEmpty {
            let opposite = palaces[index].oppositeBranch
            palaces[index].borrowedFromBranch = opposite
            palaces[index].borrowedMajorStars = palaces[opposite].majorStars.map(\.name)
        }
    }

    private static func modulo(_ value: Int, _ base: Int) -> Int {
        ((value % base) + base) % base
    }
}
