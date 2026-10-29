import Foundation

public enum BirthCalendar: String, Codable, Sendable {
    case gregorian
    case lunar
}

public enum BirthDate: Codable, Equatable, Sendable {
    case gregorian(year: Int, month: Int, day: Int)
    case lunar(year: Int, month: Int, day: Int, isLeapMonth: Bool)

    public var calendar: BirthCalendar {
        switch self {
        case .gregorian: return .gregorian
        case .lunar: return .lunar
        }
    }
}

public enum BirthTimePrecision: Codable, Equatable, Sendable {
    case exact(hour: Int, minute: Int)
    case approximate(branch: Int)
    case unknown
}

public enum Gender: String, Codable, Sendable {
    case male
    case female
}

public struct BirthLocation: Codable, Equatable, Sendable {
    public let city: String
    public let longitude: Double
    public let utcOffsetMinutes: Int

    public init(city: String, longitude: Double, utcOffsetMinutes: Int) {
        self.city = city
        self.longitude = longitude
        self.utcOffsetMinutes = utcOffsetMinutes
    }
}

public struct BirthProfile: Codable, Equatable, Sendable {
    public let id: UUID
    public var name: String
    public var gender: Gender
    public var date: BirthDate
    public var time: BirthTimePrecision
    public var location: BirthLocation?

    public init(
        id: UUID = UUID(),
        name: String,
        gender: Gender,
        date: BirthDate,
        time: BirthTimePrecision,
        location: BirthLocation? = nil
    ) {
        self.id = id
        self.name = name
        self.gender = gender
        self.date = date
        self.time = time
        self.location = location
    }
}
