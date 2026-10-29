import SwiftUI
import SwiftData

struct RootView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        if appState.records.isEmpty || appState.isCreatingRecord {
            BirthFlowView()
        } else {
            MainTabView()
        }
        .task {
            appState.configure(modelContext: modelContext)
            await purchaseManager.refreshEntitlements()
            appState.subscriptionTier = purchaseManager.hasPro ? .pro : .free
        }
    }
}

private struct MainTabView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label("今日", systemImage: "sun.max") }
            ChartHomeView()
                .tabItem { Label("命盘", systemImage: "square.grid.3x3") }
            InterpretationHomeView()
                .tabItem { Label("解读", systemImage: "text.book.closed") }
            LearnView()
                .tabItem { Label("学堂", systemImage: "graduationcap") }
            SettingsHomeView()
                .tabItem { Label("我的", systemImage: "person.crop.circle") }
        }
    }
}
