import SwiftUI
import ZiweiCore

struct TodayView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(Date.now.formatted(date: .complete, time: .omitted))
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    if let record = appState.selectedRecord {
                        GroupBox("当前命盘") {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(record.profile.name).font(.title2.bold())
                                    Text(record.chart.wuxingJuName + " · 命主 " + record.chart.mingZhu)
                                }
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                        }
                        GroupBox("今日建议") {
                            Text("先完成最重要的一件事，再处理临时信息。运势摘要提供观察角度，不代表确定事件。")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("今日")
        }
    }
}
