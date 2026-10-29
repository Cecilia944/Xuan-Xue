public enum SiHua: String, Codable, Sendable {
    case lu = "禄"
    case quan = "权"
    case ke = "科"
    case ji = "忌"
}

public enum StarBrightness: String, Codable, Sendable {
    case miao = "庙", wang = "旺", de = "得", li = "利"
    case ping = "平", bu = "不", xian = "闲", luo = "陷", di = "地"
}

public struct ZiweiStar: Codable, Equatable, Sendable {
    public let name: String
    public let brightness: StarBrightness?
    public let siHua: SiHua?
}

public struct ZiweiPalace: Codable, Equatable, Sendable {
    public let branch: Int
    public let stem: Int
    public let name: String
    public var majorStars: [ZiweiStar]
    public let isMingGong: Bool
    public let isShenGong: Bool
    public var daXianAge: AgeRange? = nil
    public var borrowedFromBranch: Int? = nil
    public var borrowedMajorStars: [String] = []
    public var isEmpty: Bool { majorStars.isEmpty }
    public var oppositeBranch: Int { (branch + 6) % 12 }
}

public struct AgeRange: Codable, Equatable, Sendable {
    public let start: Int
    public let end: Int

    public init(start: Int, end: Int) {
        self.start = start
        self.end = end
    }
}

public struct ZiweiLunarInfo: Codable, Equatable, Sendable {
    public let year: Int
    public let month: Int
    public let day: Int
    public let isLeapMonth: Bool
    public let yearStem: Int
    public let yearBranch: Int
}

public struct ZiweiChart: Codable, Equatable, Sendable {
    public let lunarInfo: ZiweiLunarInfo
    public let mingGongBranch: Int
    public let shenGongBranch: Int
    public let wuxingJu: Int
    public let wuxingJuName: String
    public let ziweiPos: Int
    public let mingZhu: String
    public let shenZhu: String
    public let yinYangGender: String
    public let palaces: [ZiweiPalace]
}

public struct ZiweiChartRequest: Sendable {
    public let profile: BirthProfile
    public let confirmedTime: ConfirmedBirthTime

    public init(profile: BirthProfile, confirmedTime: ConfirmedBirthTime) {
        self.profile = profile
        self.confirmedTime = confirmedTime
    }
}

public enum ZiweiChartError: Error, Equatable {
    case invalidDate
    case invalidBranch
    case lunarConversionFailed
}
