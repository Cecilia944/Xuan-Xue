import SwiftUI
import SwiftData
import ZiweiCore

@main
struct ZiweiApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var purchaseManager = PurchaseManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(purchaseManager)
        }
        .modelContainer(for: StoredChartRecord.self)
    }
}
