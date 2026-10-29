import SwiftUI
import ZiweiCore

struct CompassChartView: View {
    @Binding var model: ChartPresentationModel
    private let layout = CompassPalaceLayout()

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 4), spacing: 2) {
                ForEach(0..<16, id: \.self) { index in
                    let cell = CompassGridCell(column: index % 4, row: index / 4)
                    if let branch = layout.branch(at: cell),
                       let palace = model.chart.palaces.first(where: { $0.branch == branch }) {
                        Button {
                            model.selectPalace(branch: branch)
                        } label: {
                            compassCell(palace)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(model.accessibilityItems.first(where: { $0.branch == branch })?.label ?? palace.name)
                    } else {
                        centerCell(index: index)
                    }
                }
            }
            .frame(width: side, height: side)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
        .padding(.horizontal)
    }

    private func compassCell(_ palace: ZiweiPalace) -> some View {
        let highlighted = model.selection?.highlightedBranches.contains(palace.branch) == true
        return VStack(spacing: 3) {
            Text(palace.name).font(.caption.bold())
            Text(palace.majorStars.prefix(2).map(\.name).joined(separator: " "))
                .font(.caption2)
                .lineLimit(2)
            Text(branchNames[palace.branch]).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(highlighted ? Color.accentColor.opacity(0.14) : Color(.secondarySystemBackground))
        .overlay {
            Rectangle().stroke(model.selection?.branch == palace.branch ? Color.accentColor : Color(.separator), lineWidth: 1)
        }
    }

    @ViewBuilder
    private func centerCell(index: Int) -> some View {
        if index == 5 {
            VStack(spacing: 4) {
                Text(model.chart.wuxingJuName).font(.headline)
                Text("命主 \(model.chart.mingZhu)").font(.caption)
                Text("身主 \(model.chart.shenZhu)").font(.caption)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityElement(children: .combine)
        } else {
            Color.clear
        }
    }

    private let branchNames = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]
}
