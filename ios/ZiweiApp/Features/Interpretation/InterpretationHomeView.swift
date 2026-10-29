import SwiftUI
import ZiweiCore

struct InterpretationHomeView: View {
    @EnvironmentObject private var appState: AppState
    @State private var requestedFeature: ProFeature?

    var body: some View {
        NavigationStack {
            Group {
                if let record = appState.selectedRecord {
                    List {
                        Section("免费基础解读") {
                            ForEach(FreeInterpretationEngine.generate(chart: record.chart), id: \.topic) { report in
                                NavigationLink {
                                    InterpretationDetailView(report: report)
                                } label: {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(report.title).font(.headline)
                                        Text(report.conclusion).font(.subheadline).foregroundStyle(.secondary).lineLimit(2)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        Section("当前运势") {
                            Label("当前大限摘要", systemImage: "clock.arrow.circlepath")
                            Label("当前流年摘要", systemImage: "calendar")
                        }
                        Section("Pro 深度能力") {
                            proRow(.deepReport)
                            proRow(.fullCycles)
                            proRow(.aiInterpretation)
                        }
                    }
                } else {
                    ContentUnavailableView("暂无解读", systemImage: "text.book.closed")
                }
            }
            .navigationTitle("解读")
            .sheet(isPresented: paywallPresented) {
                if let requestedFeature {
                    ProPaywallView(feature: requestedFeature)
                }
            }
        }
    }

    @ViewBuilder
    private func proRow(_ feature: ProFeature) -> some View {
        let summary = InterpretationCatalog.lockedSummary(for: feature)
        Button {
            if !appState.entitlement.canAccess(feature) {
                requestedFeature = feature
            }
        } label: {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(summary.title).foregroundStyle(.primary)
                    Text(summary.preview).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                }
                Spacer()
                Image(systemName: appState.entitlement.canAccess(feature) ? "checkmark.circle.fill" : "lock.fill")
            }
        }
    }

    private var paywallPresented: Binding<Bool> {
        Binding(
            get: { requestedFeature != nil },
            set: { if !$0 { requestedFeature = nil } }
        )
    }
}

private struct InterpretationDetailView: View {
    let report: FreeInterpretationReport

    var body: some View {
        List {
            section("结论", report.conclusion)
            section("优势与课题", report.strengthsAndChallenges)
            section("命盘依据", report.evidence)
            section("行动建议", report.action)
            Section {
                Text("以上内容用于自我观察，不代表确定结果，也不替代专业建议。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(report.title)
    }

    private func section(_ title: String, _ text: String) -> some View {
        Section(title) { Text(text).textSelection(.enabled) }
    }
}
