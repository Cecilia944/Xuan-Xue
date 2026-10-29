import SwiftUI
import Foundation
import ZiweiCore

struct ProfileListView: View {
    @EnvironmentObject private var appState: AppState
    @State private var editingRecord: ChartRecord?

    var body: some View {
        List {
            ForEach(appState.records, id: \.id) { record in
                Button {
                    appState.selectedRecordID = record.id
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(record.profile.name).foregroundStyle(.primary)
                            Text(record.chart.wuxingJuName + " · " + record.chart.yinYangGender)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if appState.selectedRecordID == record.id {
                            Image(systemName: "checkmark.circle.fill")
                        }
                    }
                }
                .swipeActions(edge: .leading) {
                    Button("编辑") { editingRecord = record }
                        .tint(.blue)
                }
            }
            .onDelete { offsets in
                let ids = offsets.map { appState.records[$0].id }
                for id in ids { appState.delete(id) }
            }
        }
        .navigationTitle("命盘档案")
        .toolbar {
            Button {
                appState.isCreatingRecord = true
            } label: {
                Label("新建命盘", systemImage: "plus")
            }
            .disabled(appState.records.count >= FreeProfileLimit && !appState.entitlement.canAccess(.unlimitedProfiles))
        }
        .sheet(isPresented: editPresented) {
            if let editingRecord {
                ProfileEditView(record: editingRecord)
            }
        }
    }

    private var editPresented: Binding<Bool> {
        Binding(
            get: { editingRecord != nil },
            set: { if !$0 { editingRecord = nil } }
        )
    }
}

private struct ProfileEditView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    let record: ChartRecord

    init(record: ChartRecord) {
        self.record = record
        _name = State(initialValue: record.profile.name)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("昵称", text: $name)
                Section {
                    Text("修改昵称不会静默重新排盘；算法、内容和流派快照保持不变。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("编辑档案")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        var updated = record
                        updated.profile.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !updated.profile.name.isEmpty else { return }
                        appState.add(updated)
                        dismiss()
                    }
                }
            }
        }
    }
}
