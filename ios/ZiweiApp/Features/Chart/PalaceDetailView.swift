import SwiftUI
import ZiweiCore

struct PalaceDetailView: View {
    let palace: ZiweiPalace

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(palace.name).font(.title3.bold())
                Spacer()
                Text("三方四正").font(.caption).foregroundStyle(.secondary)
            }
            if palace.majorStars.isEmpty {
                Text("本宫无主星，参考对宫：\(palace.borrowedMajorStars.joined(separator: "、"))")
            } else {
                ForEach(palace.majorStars, id: \.name) { star in
                    HStack {
                        Text(star.name).font(.headline)
                        if let brightness = star.brightness { Text(brightness.rawValue).foregroundStyle(.secondary) }
                        if let siHua = star.siHua { Text("化\(siHua.rawValue)").foregroundStyle(.tint) }
                    }
                }
            }
            if !palace.auxiliaryStars.isEmpty {
                Text("辅曜：" + palace.auxiliaryStars.map(\.name).joined(separator: "、"))
                    .font(.subheadline)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
    }
}
