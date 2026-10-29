import Foundation

public let FreeProfileLimit = 3

public struct ChartRecord: Codable, Equatable, Sendable {
    public let id: UUID
    public var profile: BirthProfile
    public let confirmedTime: ConfirmedBirthTime
    public let chart: ZiweiChart
    public let algorithmVersion: String
    public let contentVersion: String
    public let schoolConfiguration: SchoolConfiguration

    public init(
        id: UUID,
        profile: BirthProfile,
        confirmedTime: ConfirmedBirthTime,
        chart: ZiweiChart,
        algorithmVersion: String,
        contentVersion: String,
        schoolConfiguration: SchoolConfiguration
    ) {
        self.id = id
        self.profile = profile
        self.confirmedTime = confirmedTime
        self.chart = chart
        self.algorithmVersion = algorithmVersion
        self.contentVersion = contentVersion
        self.schoolConfiguration = schoolConfiguration
    }
}

public enum ChartRepositoryError: Error, Equatable {
    case freeProfileLimitReached
    case recordNotFound
}

public enum ChartRepositoryAuditEvent: Equatable, Sendable, CustomStringConvertible {
    case saved(id: UUID)
    case updated(id: UUID)
    case deleted(id: UUID)

    public var description: String {
        switch self {
        case let .saved(id): return "chart.saved id=\(id.uuidString)"
        case let .updated(id): return "chart.updated id=\(id.uuidString)"
        case let .deleted(id): return "chart.deleted id=\(id.uuidString)"
        }
    }
}

public protocol ChartRepository {
    mutating func save(_ record: ChartRecord, entitlement: any EntitlementProvider) throws
    func list() -> [ChartRecord]
    mutating func update(_ record: ChartRecord) throws
    mutating func delete(id: UUID) throws
}

public struct InMemoryChartRepository: ChartRepository, Sendable {
    private var records: [ChartRecord] = []
    private var interpretationCache: [UUID: String] = [:]
    public private(set) var auditEvents: [ChartRepositoryAuditEvent] = []

    public init() {}

    public mutating func save(
        _ record: ChartRecord,
        entitlement: any EntitlementProvider
    ) throws {
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            records[index] = record
            auditEvents.append(.updated(id: record.id))
            return
        }
        guard records.count < FreeProfileLimit || entitlement.canAccess(.unlimitedProfiles) else {
            throw ChartRepositoryError.freeProfileLimitReached
        }
        records.append(record)
        auditEvents.append(.saved(id: record.id))
    }

    public func list() -> [ChartRecord] {
        records
    }

    public mutating func update(_ record: ChartRecord) throws {
        guard let index = records.firstIndex(where: { $0.id == record.id }) else {
            throw ChartRepositoryError.recordNotFound
        }
        records[index] = record
        auditEvents.append(.updated(id: record.id))
    }

    public mutating func delete(id: UUID) throws {
        guard let index = records.firstIndex(where: { $0.id == id }) else {
            throw ChartRepositoryError.recordNotFound
        }
        records.remove(at: index)
        interpretationCache[id] = nil
        auditEvents.append(.deleted(id: id))
    }

    public mutating func cacheInterpretation(_ content: String, for id: UUID) {
        guard records.contains(where: { $0.id == id }) else { return }
        interpretationCache[id] = content
    }

    public func cachedInterpretation(for id: UUID) -> String? {
        interpretationCache[id]
    }
}
