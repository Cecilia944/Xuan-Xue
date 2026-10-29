import SwiftUI
import ZiweiCore

struct ProfileListView: View {
    @EnvironmentObject private var appState: AppState

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
    }
}
