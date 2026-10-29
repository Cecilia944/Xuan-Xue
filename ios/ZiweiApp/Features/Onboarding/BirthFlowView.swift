import SwiftUI
import Foundation
import ZiweiCore

struct BirthFlowView: View {
    @EnvironmentObject private var appState: AppState
    @State private var name = ""
    @State private var gender: Gender = .female
    @State private var birthDate = Calendar.current.date(from: DateComponents(year: 1990, month: 1, day: 1))!
    @State private var birthTime = Calendar.current.date(from: DateComponents(hour: 12, minute: 0))!
    @State private var knowsTime = true
    @State private var unknownBranch = 6
    @State private var city = "北京"
    @State private var longitude = 116.4
    @State private var utcOffsetMinutes = 480
    @State private var flow = BirthFlowModel(profile: BirthFlowView.placeholderProfile)

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ProgressView(value: Double(flow.step.rawValue + 1), total: 4)
                    .padding(.horizontal)
                    .accessibilityLabel("排盘进度，第 \(flow.step.rawValue + 1) 步，共 4 步")
                Form {
                    content
                    if let issue = flow.issue {
                        Text(issueText(issue))
                            .foregroundStyle(.red)
                            .accessibilityLabel("无法继续：\(issueText(issue))")
                    }
                }
                controls
                    .padding()
            }
            .navigationTitle(stepTitle)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch flow.step {
        case .identity:
            Section("基本资料") {
                TextField("昵称", text: $name)
                    .textContentType(.name)
                Picker("性别", selection: $gender) {
                    Text("女").tag(Gender.female)
                    Text("男").tag(Gender.male)
                }
                .pickerStyle(.segmented)
            }
            Section {
                Text("资料默认只在本机处理。昵称仅用于区分命盘，可随时删除。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

        case .birthData:
            Section("出生日期") {
                DatePicker("公历生日", selection: $birthDate, in: dateRange, displayedComponents: .date)
                Toggle("知道出生时间", isOn: $knowsTime)
                if knowsTime {
                    DatePicker("钟表时间", selection: $birthTime, displayedComponents: .hourAndMinute)
                }
            }
            Section("出生地点") {
                TextField("城市", text: $city)
                LabeledContent("经度") {
                    TextField("经度", value: $longitude, format: .number.precision(.fractionLength(1...4)))
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numbersAndPunctuation)
                }
                LabeledContent("UTC 偏移（分钟）") {
                    TextField("UTC 偏移", value: $utcOffsetMinutes, format: .number)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numbersAndPunctuation)
                }
            }

        case .timeCorrection:
            if knowsTime, let proposal = flow.correctionProposal {
                Section("真太阳时建议") {
                    LabeledContent("校正后时间", value: String(format: "%02d:%02d", proposal.correctedHour, proposal.correctedMinute))
                    LabeledContent("时辰", value: branchNames[proposal.branch] + "时")
                    LabeledContent("日期变化", value: proposal.dayOffset == 0 ? "无" : (proposal.dayOffset > 0 ? "次日" : "前日"))
                    if proposal.chinaDSTDetected {
                        Label("检测到历史夏令时，请核对当年使用的钟表时间。", systemImage: "clock.badge.exclamationmark")
                    }
                }
                Section {
                    Text("应用不会静默改变时辰。跨日、跨时辰或历史夏令时都需要你明确确认。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            } else {
                Section("选择大致时辰") {
                    Picker("时辰", selection: $unknownBranch) {
                        ForEach(0..<12, id: \.self) { branch in
                            Text(branchNames[branch] + "时").tag(branch)
                        }
                    }
                }
                Section {
                    Label("未知时间会降低解读精度，命盘中将持续显示提醒。", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                }
            }

        case .confirmation:
            Section("确认资料") {
                LabeledContent("昵称", value: name)
                LabeledContent("日期", value: birthDate.formatted(date: .long, time: .omitted))
                LabeledContent("城市", value: city)
                if let confirmed = flow.confirmedTime {
                    LabeledContent("采用时辰", value: branchNames[confirmed.branch] + "时")
                }
            }
            Section {
                Text("生成后可在“我的”中编辑或删除。排盘用于自我观察，不替代医疗、法律或财务建议。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var controls: some View {
        HStack {
            if flow.step != .identity {
                Button("返回") { flow.goBack() }
            }
            Spacer()
            Button(flow.step == .confirmation ? "生成命盘" : "继续") {
                advance()
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func advance() {
        flow.profile = makeProfile()
        switch flow.step {
        case .timeCorrection:
            if knowsTime {
                flow.confirmTimeCorrection()
            } else {
                flow.selectUnknownTimeBranch(unknownBranch)
            }
            _ = flow.advance()
        case .confirmation:
            guard let draft = flow.generateDraft() else { return }
            appState.add(
                ChartRecord(
                    id: draft.profile.id,
                    profile: draft.profile,
                    confirmedTime: draft.confirmedTime,
                    chart: draft.chart,
                    algorithmVersion: "swift-core-1",
                    contentVersion: "content-2026.10",
                    schoolConfiguration: .default
                )
            )
        default:
            _ = flow.advance()
        }
    }

    private func makeProfile() -> BirthProfile {
        let dateParts = Calendar.current.dateComponents([.year, .month, .day], from: birthDate)
        let timeParts = Calendar.current.dateComponents([.hour, .minute], from: birthTime)
        return BirthProfile(
            id: flow.profile.id,
            name: name,
            gender: gender,
            date: .gregorian(year: dateParts.year!, month: dateParts.month!, day: dateParts.day!),
            time: knowsTime ? .exact(hour: timeParts.hour!, minute: timeParts.minute!) : .unknown,
            location: BirthLocation(city: city, longitude: longitude, utcOffsetMinutes: utcOffsetMinutes)
        )
    }

    private var stepTitle: String {
        switch flow.step {
        case .identity: "开始排盘"
        case .birthData: "出生资料"
        case .timeCorrection: "时间校正"
        case .confirmation: "确认并生成"
        }
    }

    private func issueText(_ issue: BirthFlowIssue) -> String {
        switch issue {
        case .missingName: "请填写昵称"
        case .invalidDate: "出生日期无效"
        case .timeCorrectionFailed: "无法完成时间校正，请检查时间和地点"
        case .unknownTimeRequiresBranch: "请选择一个大致时辰"
        case .timeCorrectionConfirmationRequired: "请确认校正后的时间"
        case .chartGenerationFailed: "命盘生成失败，请返回检查资料"
        }
    }

    private var dateRange: ClosedRange<Date> {
        Calendar.current.date(from: DateComponents(year: 1900, month: 1, day: 1))! ...
        Calendar.current.date(from: DateComponents(year: 2050, month: 12, day: 31))!
    }

    private let branchNames = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]

    private static let placeholderProfile = BirthProfile(
        name: "",
        gender: .female,
        date: .gregorian(year: 1990, month: 1, day: 1),
        time: .exact(hour: 12, minute: 0),
        location: BirthLocation(city: "北京", longitude: 116.4, utcOffsetMinutes: 480)
    )
}
