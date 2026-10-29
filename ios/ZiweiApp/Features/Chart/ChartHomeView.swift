import SwiftUI
import ZiweiCore

struct ChartHomeView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            if let record = appState.selectedRecord {
                ChartContent(record: record)
                    .id(record.id)
            } else {
                ContentUnavailableView("暂无命盘", systemImage: "square.grid.3x3", description: Text("请先创建命盘档案"))
            }
        }
    }
}

private struct ChartContent: View {
    let record: ChartRecord
    @State private var model: ChartPresentationModel
    @State private var shareOptionsPresented = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    init(record: ChartRecord) {
        self.record = record
        _model = State(initialValue: ChartPresentationModel(chart: record.chart))
    }

    var body: some View {
        VStack(spacing: 12) {
            Picker("命盘显示方式", selection: modeBinding) {
                Text("卡片").tag(ChartDisplayMode.card)
                Text("罗盘").tag(ChartDisplayMode.compass)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            if usesSplitLayout {
                HStack(alignment: .top, spacing: 0) {
                    chartBody
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    Divider()
                    detailBody
                        .frame(width: 340, alignment: .top)
                }
            } else {
                chartBody
                detailBody
            }
        }
        .navigationTitle(record.profile.name + "的命盘")
        .animation(reduceMotion ? nil : .snappy, value: model.selection?.branch)
        .toolbar {
            Button {
                shareOptionsPresented = true
            } label: {
                Label("分享脱敏命盘", systemImage: "square.and.arrow.up")
            }
        }
        .sheet(isPresented: $shareOptionsPresented) {
            ChartShareOptionsView(record: record)
                .presentationDetents([.medium, .large])
        }
    }

    private var modeBinding: Binding<ChartDisplayMode> {
        Binding(get: { model.displayMode }, set: { model.setDisplayMode($0) })
    }

    @ViewBuilder
    private var chartBody: some View {
        switch model.displayMode {
        case .card:
            CardChartView(model: $model)
        case .compass:
            CompassChartView(model: $model)
        }
    }

    @ViewBuilder
    private var detailBody: some View {
        if let palace = model.selectedPalace {
            PalaceDetailView(palace: palace)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        } else if usesSplitLayout {
            ContentUnavailableView(
                "选择一个宫位",
                systemImage: "hand.tap",
                description: Text("查看星曜、四化和三方四正")
            )
        }
    }

    private var usesSplitLayout: Bool {
        horizontalSizeClass == .regular || verticalSizeClass == .compact
    }

}
