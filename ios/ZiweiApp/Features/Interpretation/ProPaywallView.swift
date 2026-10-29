import SwiftUI
import ZiweiCore

struct ProPaywallView: View {
    let feature: ProFeature
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var purchaseManager: PurchaseManager

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "sparkles")
                    .font(.system(size: 52))
                    .foregroundStyle(.tint)
                let summary = InterpretationCatalog.lockedSummary(for: feature)
                Text(summary.title).font(.largeTitle.bold()).multilineTextAlignment(.center)
                Text(summary.preview).font(.title3).foregroundStyle(.secondary).multilineTextAlignment(.center)
                VStack(alignment: .leading, spacing: 12) {
                    Label("13 维深度报告与完整运限", systemImage: "checkmark.circle")
                    Label("AI 解读附命盘依据", systemImage: "checkmark.circle")
                    Label("无限档案与专业导出", systemImage: "checkmark.circle")
                }
                ForEach(purchaseManager.products, id: \.id) { product in
                    Button("\(product.displayName) · \(product.displayPrice)") {
                        Task {
                            if await purchaseManager.purchase(product) {
                                appState.subscriptionTier = .pro
                                dismiss()
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                if purchaseManager.products.isEmpty {
                    ProgressView("载入订阅方案")
                }
                Button("恢复购买") {
                    Task {
                        await purchaseManager.restorePurchases()
                        appState.subscriptionTier = purchaseManager.hasPro ? .pro : .free
                        if purchaseManager.hasPro { dismiss() }
                    }
                }
                if let errorMessage = purchaseManager.errorMessage {
                    Text(errorMessage).font(.footnote).foregroundStyle(.red)
                }
                Button("暂不升级") { dismiss() }
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("Ziwei Pro")
            .navigationBarTitleDisplayMode(.inline)
            .task { await purchaseManager.loadProducts() }
        }
    }
}
