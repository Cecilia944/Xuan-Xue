import Foundation
import Combine
import SwiftData
import ZiweiCore

@MainActor
final class AppState: ObservableObject {
    @Published private(set) var records: [ChartRecord] = []
    @Published var selectedRecordID: UUID?
    @Published var subscriptionTier: SubscriptionTier = .free
    @Published var isCreatingRecord = false
    private var modelContext: ModelContext?
    private var hasLoadedPersistentRecords = false

    var selectedRecord: ChartRecord? {
        guard let selectedRecordID else { return records.first }
        return records.first { $0.id == selectedRecordID }
    }

    var entitlement: DefaultEntitlementProvider {
        DefaultEntitlementProvider(tier: subscriptionTier)
    }

    func add(_ record: ChartRecord) {
        guard records.contains(where: { $0.id == record.id })
                || records.count < FreeProfileLimit
                || entitlement.canAccess(.unlimitedProfiles)
        else { return }
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            records[index] = record
        } else {
            records.append(record)
        }
        selectedRecordID = record.id
        isCreatingRecord = false
        persist(record)
    }

    func delete(_ id: UUID) {
        records.removeAll { $0.id == id }
        if selectedRecordID == id {
            selectedRecordID = records.first?.id
        }
        if let stored = storedRecords().first(where: { $0.id == id }) {
            modelContext?.delete(stored)
            try? modelContext?.save()
        }
    }

    func deleteAllLocalData() {
        records.removeAll()
        selectedRecordID = nil
        for stored in storedRecords() { modelContext?.delete(stored) }
        try? modelContext?.save()
    }

    func configure(modelContext: ModelContext) {
        guard !hasLoadedPersistentRecords else { return }
        hasLoadedPersistentRecords = true
        self.modelContext = modelContext
        if CommandLine.arguments.contains("-ui-testing-reset") {
            for stored in storedRecords() { modelContext.delete(stored) }
            try? modelContext.save()
        }
        let decoder = JSONDecoder()
        records = storedRecords().compactMap { try? decoder.decode(ChartRecord.self, from: $0.payload) }
        selectedRecordID = records.first?.id
    }

    private func persist(_ record: ChartRecord) {
        guard let modelContext, let data = try? JSONEncoder().encode(record) else { return }
        if let stored = storedRecords().first(where: { $0.id == record.id }) {
            stored.payload = data
            stored.updatedAt = .now
        } else {
            modelContext.insert(StoredChartRecord(id: record.id, payload: data))
        }
        try? modelContext.save()
    }

    private func storedRecords() -> [StoredChartRecord] {
        guard let modelContext else { return [] }
        let descriptor = FetchDescriptor<StoredChartRecord>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
}
