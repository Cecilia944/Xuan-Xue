import SwiftUI
import UIKit
import ZiweiCore

@MainActor
enum ChartShareRenderer {
    static func render(
        record: ChartRecord,
        privacy: SharePrivacyOptions = .default
    ) -> UIImage? {
        let content = ChartShareContentBuilder.build(record: record, privacy: privacy)
        let renderer = ImageRenderer(content: ChartShareCard(content: content))
        renderer.scale = UIScreen.main.scale
        renderer.proposedSize = ProposedViewSize(width: 1080, height: nil)
        return renderer.uiImage
    }
}

private struct ChartShareCard: View {
    let content: ChartShareContent

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(content.chartTitle).font(.largeTitle.bold())
                    if let nickname = content.nickname { Text(nickname).font(.title2) }
                    Text("采用时辰：\(content.birthTimeLabel)").foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "sparkles").font(.system(size: 44)).foregroundStyle(.tint)
            }
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(Array(content.palaceSummaries.enumerated()), id: \.offset) { _, palace in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack { Text(palace.name).font(.headline); Spacer(); Text(palace.branch).foregroundStyle(.secondary) }
                        Text(palace.stars.isEmpty ? "空宫 · 参考对宫" : palace.stars.joined(separator: " · "))
                            .font(.subheadline)
                            .lineLimit(3)
                    }
                    .frame(maxWidth: .infinity, minHeight: 92, alignment: .topLeading)
                    .padding()
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
                }
            }
            Divider()
            Text("默认隐藏姓名、精确分钟与出生地点 · 紫微斗数 iOS")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(36)
        .background(Color(.systemBackground))
        .frame(width: 1080)
    }
}

struct ActivityShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
