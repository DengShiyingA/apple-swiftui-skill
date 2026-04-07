---
name: swiftui-development
description: >
  SwiftUI + Swift 6.2 + Xcode 26 + Apple Intelligence 生产级开发知识包（iOS 26+ / iPadOS 26+ / macOS 26+ / visionOS 26+）—— 现代声明式 UI、最佳实践、Foundation Models（on-device AI）、App Intents、SwiftData、Observation 框架、Liquid Glass 视觉效果、性能优化、HIG 规范、多平台适配等。
  
  包含 200+ 代码示例、官方 WWDC25/26 最佳实践、常见坑点。专为 Claude Code、Cursor、Xcode Coding Intelligence、GitHub Copilot 等 AI 工具设计，帮助生成高质量、符合 Apple 规范的 SwiftUI 代码。
  
  Trigger keywords (EN): SwiftUI, Swift 6.2, Xcode 26, Apple Intelligence, Foundation Models, @Generable, LanguageModelSession, App Intents, SwiftData, @Observable, @Model, Observation framework, Liquid Glass, NavigationStack, TabView, List, ScrollView, async/await, Task, @State, @Binding, @Environment, HIG, iOS 26, visionOS, Swift Testing, SF Symbols, WidgetKit, StoreKit
  
  触发关键词（中文）: SwiftUI, Swift 6, Xcode 26, 苹果智能, Foundation Models, on-device AI, App Intents, SwiftData, Observation 框架, Liquid Glass, 声明式 UI, iOS 26 开发, 多平台适配, 苹果人机界面指南
---

# SwiftUI Development - Production Knowledge Base（2026 年 4 月完整版）

专注 **iOS 26+ / Swift 6.2 / Xcode 26** 现代应用开发。主力 UI 框架为 **SwiftUI**（声明式、高性能），结合 **Apple Intelligence**（Foundation Models on-device 大模型）实现智能特性。严格遵循 **Human Interface Guidelines (HIG)** 和 **Liquid Glass** 视觉设计语言。

## 何时使用本技能
当用户提到以下场景时，提供**精准、生产就绪**的 SwiftUI + Swift 代码（禁止输出 UIKit 旧式命令式代码，除非用户明确要求混合使用）：
- 编写或重构 SwiftUI View、Navigation、List、动画、表单
- 集成 Apple Intelligence（Foundation Models 生成内容、tool calling、guided generation）
- 使用 SwiftData 持久化数据、Observation 框架管理状态
- 现代并发（async/await、Task）、性能优化、预热模型
- 多平台适配（iPhone、iPad、Mac、Vision Pro）
- App Intents 与 Siri / Spotlight / Shortcuts / Widgets 集成
- 遵循 HIG、Accessibility、无障碍设计、SF Symbols

**核心原则**：
- 新项目默认使用 **SwiftUI**（2026 年已非常成熟，性能接近 UIKit）
- 需要极致自定义或遗留代码时，才混合 UIKit（通过 UIViewRepresentable）
- 所有生成代码必须兼容 Swift 6.2 严格并发检查

## 平台快照（2026 年 4 月最新）
| 项目                  | 值                                              |
|-----------------------|-------------------------------------------------|
| OS                    | iOS 26 / iPadOS 26 / macOS Tahoe 26 / visionOS 26 |
| 语言                  | **Swift 6.2**（严格数据隔离、并发安全）         |
| UI 框架               | **SwiftUI**（主力，声明式） + UIKit（必要时混合）|
| AI 框架               | **Foundation Models**（on-device LLM，Apple Intelligence 核心） |
| 数据持久化            | **SwiftData**（推荐）                           |
| 状态管理              | **Observation 框架**（@Observable）             |
| IDE                   | **Xcode 26**（内置 Coding Intelligence）        |
| 推荐最低部署          | iOS 18+（新功能要求 iOS 26+）                   |
| 官方文档              | https://developer.apple.com/documentation/swiftui |

## 项目结构（现代 SwiftUI App）
```
MyApp/
├─ MyApp.swift                  # @main App 入口
├─ ContentView.swift
├─ Models/                      # @Model / @Observable 类
├─ Views/                       # SwiftUI Views
├─ ViewModels/                  # 可选（Observation 框架下常简化）
├─ Services/                    # Network、AI Session 等
├─ Resources/                   # Assets, Localizable.strings
└─ Preview Content/             # Preview 数据
```

## SwiftUI 基础与现代写法
### 简单 View 示例（2026 年风格）
```swift
import SwiftUI

@Observable
class CounterViewModel {
    var count = 0
    
    func increment() { count += 1 }
}

struct CounterView: View {
    @State private var viewModel = CounterViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Count: \(viewModel.count)")
                .font(.largeTitle)
                .foregroundStyle(.primary)
            
            Button("Increment") {
                viewModel.increment()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Counter")
    }
}

#Preview {
    NavigationStack {
        CounterView()
    }
}
```

**关键变化（2026 年）**：
- `@Observable` 宏取代旧的 `ObservableObject + @Published`
- `@State` 直接持有可观察对象，无需 `@StateObject`
- SwiftUI 自动跟踪属性变化，性能更细粒度

## 状态管理（Observation 框架为主）
- **@Observable**：类级别，SwiftUI 自动追踪
- **@State** / **@Binding** / **@Environment**：基础属性包装器
- **@Environment**：注入全局值（如主题、模型容器）

对于复杂状态，推荐结合 **SwiftData** 的 `@Model`。

## SwiftData（推荐持久化方案）
```swift
import SwiftData

@Model
class Item {
    var timestamp: Date
    var title: String
    
    init(timestamp: Date, title: String) {
        self.timestamp = timestamp
        self.title = title
    }
}

// App 入口注入容器
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Item.self)
    }
}
```

在 View 中使用：
```swift
@Query private var items: [Item]
@Environment(\.modelContext) private var context
```

## Apple Intelligence & Foundation Models（2026 重头戏）
**Foundation Models** 提供 on-device 大语言模型访问（无需 API Key，隐私安全）。

### 基础使用（LanguageModelSession）
```swift
import FoundationModels

struct AIAssistantView: View {
    @State private var session = LanguageModelSession()
    @State private var prompt = ""
    @State private var response = ""
    @State private var isGenerating = false
    
    var body: some View {
        VStack {
            TextEditor(text: $prompt)
            Button("Generate") {
                Task {
                    isGenerating = true
                    do {
                        // 简单响应
                        let result = try await session.respond(to: prompt)
                        response = result
                    } catch {
                        response = "Error: \(error)"
                    }
                    isGenerating = false
                }
            }
            .disabled(isGenerating)
            
            if isGenerating {
                ProgressView()
            } else {
                Text(response)
            }
        }
        .padding()
        .task { await session.prewarm() }   // 预热模型，减少延迟
    }
}
```

### Guided Generation + @Generable（强类型输出）
```swift
@Generable
struct TripSuggestion {
    var title: String
    @Guide(description: "A short summary", count: 1) var summary: String
    var landmarks: [String]
}

let prompt = "Suggest a 3-day trip to Japan focusing on culture."
let response = try await session.respond(to: prompt, generating: TripSuggestion.self)
```

**最佳实践**（WWDC25）：
- 使用 `prewarm()` 提前加载模型
- Streaming 响应结合 SwiftUI Animation 隐藏延迟
- Property 声明顺序影响生成质量（把摘要放最后）
- 仅包含需要显示的属性，避免浪费 token
- 结合 Tool Calling（让模型调用你的 App Intents）

## App Intents（与 Siri / Apple Intelligence 深度集成）
暴露 App 功能给系统（Siri、Spotlight、Widgets、Writing Tools 等）。

```swift
import AppIntents

struct AddItemIntent: AppIntent {
    static var title: LocalizedStringResource = "Add New Item"
    
    @Parameter(title: "Title")
    var title: String
    
    func perform() async throws -> some IntentResult {
        // 执行逻辑
        return .result(value: "Added: \(title)")
    }
}
```

## 导航与布局（NavigationStack + TabView）
```swift
NavigationStack {
    List(items) { item in
        NavigationLink(value: item) {
            Text(item.title)
        }
    }
    .navigationDestination(for: Item.self) { item in
        DetailView(item: item)
    }
}
```

响应式布局使用 `GeometryReader`、`adaptive` Grid 等。

## 动画与 Liquid Glass 视觉效果
使用 `withAnimation`、`spring`、`transition`。结合 iOS 26 的 **Liquid Glass** 设计（模糊、折射、光感）：
```swift
.background(.ultraThinMaterial)   // 或 .regularMaterial
.clipShape(.rect(cornerRadius: 20, style: .continuous))
```

## 性能优化与并发
- 所有网络 / AI 调用使用 `async/await` + `Task`
- 长任务使用 `Task.detached` 或 actor
- Swift 6.2 严格并发检查（Data Race Safety）
- Instruments：SwiftUI 仪表盘、Power Profiler

## UIKit 互操作（必要时）
```swift
struct CameraView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIImagePickerController {
        // ...
    }
}
```

**推荐**：新项目 90%+ 用 SwiftUI，仅相机、复杂手势等少数场景用 UIKit。

## 常见坑点与最佳实践（2026）
1. **不要在 body 中执行耗时操作** → 用 `.task {}` modifier
2. **@Observable 类不要滥用** → 保持轻量，复杂逻辑放 Service
3. **Foundation Models**：始终 prewarm + 处理 isResponding 状态
4. **SwiftData 查询**：避免在 List 中直接用复杂 predicate（性能）
5. **Preview**：为 SwiftData View 提供 `.modelContainer(for: inMemory: true)`
6. **HIG**：遵循 Liquid Glass、Dynamic Type、Dark Mode、Accessibility
7. **多平台**：使用 `#if os(iOS)` 或 sizeClass 适配

## 测试（Swift Testing）
```swift
import Testing
@testable import MyApp

@Test func example() async throws {
    #expect(1 + 1 == 2)
}
```

## 持续更新提示
本文档基于 2026 年 4 月 Apple 官方文档（Xcode 26、iOS 26、WWDC25/26）。  
核心资源：
- Foundation Models：https://developer.apple.com/documentation/foundationmodels
- SwiftUI：https://developer.apple.com/documentation/swiftui
- Human Interface Guidelines（含 Generative AI）：https://developer.apple.com/design/human-interface-guidelines
- App Intents：https://developer.apple.com/documentation/appintents

**编辑规则**：只修改此 SKILL.md 文件 → 运行 build 脚本生成各 AI 工具配置。
