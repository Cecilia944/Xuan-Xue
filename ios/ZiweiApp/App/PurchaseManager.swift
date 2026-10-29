import Foundation
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    static let productIDs = [
        "com.ziwei.app.pro.monthly",
        "com.ziwei.app.pro.yearly",
    ]

    @Published private(set) var products: [Product] = []
    @Published private(set) var hasPro = false
    @Published private(set) var errorMessage: String?

    func loadProducts() async {
        do {
            products = try await Product.products(for: Self.productIDs)
                .sorted { $0.price < $1.price }
            await refreshEntitlements()
        } catch {
            errorMessage = "暂时无法载入订阅方案，请稍后再试。"
        }
    }

    func purchase(_ product: Product) async -> Bool {
        do {
            switch try await product.purchase() {
            case let .success(result):
                guard case let .verified(transaction) = result else {
                    errorMessage = "购买验证失败，请稍后恢复购买。"
                    return false
                }
                await transaction.finish()
                await refreshEntitlements()
                return hasPro
            case .pending:
                errorMessage = "购买正在等待批准。"
                return false
            case .userCancelled:
                return false
            @unknown default:
                return false
            }
        } catch {
            errorMessage = "购买未完成，请检查网络或稍后再试。"
            return false
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
        } catch {
            errorMessage = "恢复购买失败，请稍后再试。"
        }
    }

    func refreshEntitlements() async {
        var active = false
        for await result in Transaction.currentEntitlements {
            if case let .verified(transaction) = result,
               Self.productIDs.contains(transaction.productID),
               transaction.revocationDate == nil {
                active = true
            }
        }
        hasPro = active
    }
}
