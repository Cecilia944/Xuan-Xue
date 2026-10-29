# 紫微斗数 iOS

这是面向大众的原生 iOS 版本实现目录。当前可移植的 `ZiweiCore` 已覆盖出生资料验证、真太阳时、基础排盘、命盘展示状态、Free/Pro 权益、档案仓库合同和隐私安全分享内容。

## 产品分层

- Free：基础排盘、十二宫、星曜、亮度、本命四化、卡片/罗盘模式、五项基础解读、当前大限与流年摘要，以及最多三张本地档案。
- Pro：13 维深度报告、完整运限、AI 解读、专业流派设置、无限档案、PDF/JSON 导出和 iCloud 同步。
- 首次排盘前不展示付费墙；所有 Pro 入口统一使用 `EntitlementProvider`。

## 隐私

- 排盘核心和分享内容准备默认离线完成。
- 默认分享不包含姓名、精确分钟、城市、经纬度或 UTC 偏移；用户只能显式选择是否加入昵称。
- 档案审计事件只记录随机标识符和操作类型，不记录出生资料。
- 删除档案时必须同时删除该档案的本地解读缓存。
- 用户可在“我的 → 命盘档案”中删除单张档案；“我的 → 隐私与数据 → 删除全部本地数据”将由 App 层调用仓库清理接口。

`ZiweiApp/Resources/PrivacyInfo.xcprivacy` 当前声明不跟踪、不采集数据，也不使用需申报的 Required Reason API。接入 StoreKit、CloudKit、分析或崩溃服务时必须同步更新该清单和 App Store 隐私标签。

## 验证

当前机器仅安装 Command Line Tools，可运行可移植核心：

```sh
swift run --package-path ios/Packages/ZiweiCore ZiweiCoreTests
npm test
```

完整 SwiftUI、SwiftData、StoreKit 2、图片渲染、VoiceOver 和设备布局验收需要完整 Xcode。仓库已提供 `ios/project.yml`，安装 XcodeGen 后可生成工程：

```sh
brew install xcodegen
cd ios
xcodegen generate
open ZiweiApp.xcodeproj
```

生成的 iOS 17+ App target 会自动引入本地 `ZiweiCore`、SwiftData 模型和隐私清单。运行购买流程前，请在 App Store Connect 或 StoreKit Configuration 中建立以下订阅产品：

- `com.ziwei.app.pro.monthly`
- `com.ziwei.app.pro.yearly`

## 来源与许可

- 上游项目：[Renhuai123/ziwei-doushu](https://github.com/Renhuai123/ziwei-doushu)
- 应用代码继承并保留上游 MIT License 署名，详见仓库根目录 `LICENSE`。
- 若使用上游 13 维解读数据，按 CC BY 4.0 保留来源标注，详见 `DATASET-LICENSE`。
- `docs/tianji-ziwei/` 为 CC BY-NC-SA 4.0，不能默认纳入商业版内容。
