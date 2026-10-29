import SwiftUI
import ZiweiCore

struct SettingsHomeView: View {
    @EnvironmentObject private var appState: AppState
    @State private var confirmsDeleteAll = false

    var body: some View {
        NavigationStack {
            List {
                Section("档案") {
                    NavigationLink("命盘档案（\(appState.records.count)）") { ProfileListView() }
                    Button("新建命盘") { appState.isCreatingRecord = true }
                        .disabled(appState.records.count >= FreeProfileLimit && !appState.entitlement.canAccess(.unlimitedProfiles))
                }
                Section("版本") {
                    LabeledContent("当前方案", value: appState.subscriptionTier == .pro ? "Pro" : "Free")
                    LabeledContent("排盘核心", value: "swift-core-1")
                    LabeledContent("内容版本", value: "content-2026.10")
                }
                Section("隐私与数据") {
                    Text("出生资料默认只保存在本机；分享默认隐藏姓名、分钟和地点。")
                    Button("删除全部本地数据", role: .destructive) { confirmsDeleteAll = true }
                }
                Section("来源与许可") {
                    Link("上游项目 Renhuai123/ziwei-doushu", destination: URL(string: "https://github.com/Renhuai123/ziwei-doushu")!)
                    Text("代码：MIT。解读数据：CC BY 4.0。商业版本不默认包含非商业许可内容。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("我的")
            .confirmationDialog("删除全部本地数据？", isPresented: $confirmsDeleteAll, titleVisibility: .visible) {
                Button("永久删除", role: .destructive) { appState.deleteAllLocalData() }
                Button("取消", role: .cancel) {}
            } message: {
                Text("这会删除所有命盘和本地解读缓存，无法撤销。")
            }
        }
    }
}
