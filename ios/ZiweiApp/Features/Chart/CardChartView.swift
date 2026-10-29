import SwiftUI
import ZiweiCore

struct CardChartView: View {
    @Binding var model: ChartPresentationModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(model.chart.palaces, id: \.branch) { palace in
                    Button {
                        model.selectPalace(branch: palace.branch)
                    } label: {
                        PalaceCard(
                            palace: palace,
                            selected: model.selection?.branch == palace.branch,
                            highlighted: model.selection?.highlightedBranches.contains(palace.branch) == true
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(accessibilityLabel(for: palace))
                    .accessibilityHint("轻点查看宫位详情和三方四正")
                }
            }
            .padding(.horizontal)
        }
    }

    private func accessibilityLabel(for palace: ZiweiPalace) -> String {
        model.accessibilityItems.first(where: { $0.branch == palace.branch })?.label ?? palace.name
    }
}

private struct PalaceCard: View {
    let palace: ZiweiPalace
    let selected: Bool
    let highlighted: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(palace.name)
                    .font(.headline)
                Text(branchNames[palace.branch])
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 64, alignment: .leading)
            VStack(alignment: .leading, spacing: 6) {
                Text(starText)
                    .font(.body)
                if let range = palace.daXianAge {
                    Text("大限 \(range.start)–\(range.end) 岁")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            if palace.isMingGong || palace.isShenGong {
                Text(palace.isMingGong ? "命" : "身")
                    .font(.caption.bold())
                    .padding(6)
                    .background(.tint.opacity(0.15), in: Circle())
            }
        }
        .padding()
        .background(highlighted ? Color.accentColor.opacity(0.09) : Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(selected ? Color.accentColor : .clear, lineWidth: 2)
        }
    }

    private var starText: String {
        let stars = palace.majorStars + palace.auxiliaryStars
        return stars.isEmpty ? "空宫 · 参考对宫" : stars.map(\.name).joined(separator: " · ")
    }

    private let branchNames = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]
}
