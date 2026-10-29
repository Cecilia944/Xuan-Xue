import Foundation
import SwiftData

@Model
final class StoredChartRecord {
    @Attribute(.unique) var id: UUID
    var payload: Data
    var updatedAt: Date

    init(id: UUID, payload: Data, updatedAt: Date = .now) {
        self.id = id
        self.payload = payload
        self.updatedAt = updatedAt
    }
}
