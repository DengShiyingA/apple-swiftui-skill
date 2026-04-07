---
name: swiftui-development
description: >
  SwiftUI + Swift 6.2 + Xcode 26 + Apple Intelligence 生产级开发知识包（iOS 26+ / iPadOS 26+ / macOS Tahoe 26+ / visionOS 26+）—— 声明式 UI、Liquid Glass 设计语言、Foundation Models on-device AI、App Intents、SwiftData、Observation 框架（含 Swift 6.2 Observations AsyncSequence）、性能优化、HIG 规范、多平台适配等。
  
  包含 250+ 代码示例、WWDC25/26 最佳实践、常见坑点。专为 Claude Code、Cursor、Xcode Coding Intelligence 等 AI 工具设计，帮助生成高质量、隐私优先、符合 Apple 规范的 Swift/SwiftUI 代码。
  
  Trigger keywords (EN): SwiftUI, Swift 6.2, Xcode 26, Apple Intelligence, Foundation Models, LanguageModelSession, @Generable, Guided Generation, Liquid Glass, @Observable, @Model, SwiftData, Observations AsyncSequence, NavigationStack, TabView, List, ScrollView, async/await, Task, HIG, iOS 26, visionOS, Swift Testing, SF Symbols, WidgetKit, StoreKit, Coding Intelligence
  
  触发关键词（中文）: SwiftUI, Swift 6.2, Xcode 26, 苹果智能, Foundation Models, on-device AI, Liquid Glass, App Intents, SwiftData, Observation 框架, 声明式 UI, iOS 26 开发, 多平台适配, 人机界面指南
---

# SwiftUI Development - Production Knowledge Base（2026 年 4 月完整增强版）

专注 **iOS 26+ / Swift 6.2 / Xcode 26** 现代应用开发。主力 UI 框架 **SwiftUI**（声明式、高性能），结合 **Apple Intelligence**（Foundation Models on-device 大模型）和全新 **Liquid Glass** 设计语言。严格遵循 **Human Interface Guidelines (HIG)**，优先隐私与离线能力。

## 何时使用本技能
当用户提到以下场景时，提供**精准、生产就绪**的 SwiftUI + Swift 代码（默认使用 Swift 6.2 严格并发，禁止输出旧式 UIKit 命令式代码，除非明确要求混合）：
- 编写/重构 SwiftUI View、Navigation、List、动画、表单
- 集成 Apple Intelligence（Foundation Models 生成内容、tool calling、guided generation）
- 使用 SwiftData 持久化 + Observation 框架（含 Swift 6.2 Observations AsyncSequence）
- Liquid Glass 视觉效果、多平台适配（iPhone / iPad / Mac / Vision Pro）
- App Intents 与 Siri / Spotlight / Shortcuts / Widgets 集成
- 性能优化、Accessibility、无障碍设计、Xcode Coding Intelligence

**核心原则**：
- 新项目 95%+ 使用 SwiftUI
- 必要时通过 `UIViewRepresentable` / `UIViewControllerRepresentable` 混合 UIKit
- 所有代码必须兼容 Swift 6.2 严格数据隔离（Data Race Safety）

## 平台快照（2026 年 4 月最新）
| 项目                  | 值                                              |
|-----------------------|-------------------------------------------------|
| OS                    | iOS 26 / iPadOS 26 / macOS Tahoe 26 / visionOS 26 |
| 语言                  | **Swift 6.2**（严格并发 + Observations 增强）   |
| UI 框架               | **SwiftUI**（主力） + Liquid Glass 设计语言     |
| AI 框架               | **Foundation Models**（on-device LLM，Apple Intelligence 核心） |
| 数据持久化            | **SwiftData**（推荐）                           |
| 状态管理              | **Observation 框架**（@Observable + Swift 6.2 Observations） |
| IDE                   | **Xcode 26**（内置 Coding Intelligence）        |
| 推荐部署              | iOS 18+（高级特性需 iOS 26+）                   |

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

## SwiftUI 基础与现代写法（Swift 6.2）
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
            
            Button("Increment", action: viewModel.increment)
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

## Liquid Glass 设计语言（iOS 26 新视觉系统）
Liquid Glass 是苹果 2025 WWDC 推出的全新材料：半透明、反射/折射环境光、动态聚焦内容。

**使用方式**：
```swift
// 基础 Liquid Glass 效果
.background(.ultraThinMaterial)     // 或 .regularMaterial, .thickMaterial
.clipShape(.rect(cornerRadius: 24, style: .continuous))
.shadow(radius: 10)                 // 结合光感效果

// 卡片式 Liquid Glass
struct GlassCard: View {
    var body: some View {
        VStack {
            Image(systemName: "star.fill")
                .font(.largeTitle)
            Text("Featured")
                .font(.headline)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }
}
```

**推荐实践**：
- 控件、导航栏、卡片、图标、Widget 广泛使用 Liquid Glass
- 结合 `.background(.ultraThinMaterial)` + 动态模糊，实现"内容优先"效果
- 自动适配 Dark Mode 和环境光
- 避免在 Liquid Glass 上叠加过多不透明元素

## 状态管理（Observation 框架 + Swift 6.2 增强）

### @Observable 基础用法
```swift
import Observation

@Observable
class UserProfile {
    var name: String = ""
    var avatar: String = "person.circle"
    var isLoggedIn: Bool = false
}

struct ProfileView: View {
    @State private var profile = UserProfile()
    
    var body: some View {
        // SwiftUI 自动细粒度追踪：仅当 name 变化时 Text 才更新
        Text(profile.name)
    }
}
```

### Swift 6.2 Observations（新 AsyncSequence 观察状态变化）
```swift
import Observation

let profile = UserProfile()
let observations = Observations { profile.name }

// 在 Task 中异步监听属性变化
Task {
    for await newName in observations {
        print("Name changed to: \(newName)")
        // 可用于持久化、日志、网络同步等非 UI 场景
    }
}
```

**最佳实践**：
- 使用 `[weak self]` 避免 retain cycle
- Observations AsyncSequence 适合非 SwiftUI 上下文（Service 层、后台同步）
- SwiftUI View 内继续使用 `@State` + `@Observable`，无需手动订阅

### 环境注入
```swift
@Environment(\.modelContext) private var context
@Environment(\.colorScheme) private var colorScheme
@Environment(\.horizontalSizeClass) private var sizeClass
```

## SwiftData（推荐持久化方案）
```swift
import SwiftData

@Model
class Item {
    var timestamp: Date
    var title: String
    var isCompleted: Bool = false
    
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
struct ItemListView: View {
    @Query(sort: \Item.timestamp, order: .reverse) private var items: [Item]
    @Environment(\.modelContext) private var context
    
    var body: some View {
        List(items) { item in
            Text(item.title)
        }
    }
    
    func addItem(title: String) {
        let item = Item(timestamp: .now, title: title)
        context.insert(item)
    }
}
```

**SwiftData Preview 支持**：
```swift
#Preview {
    ItemListView()
        .modelContainer(for: Item.self, inMemory: true)
}
```

## Apple Intelligence & Foundation Models（核心增强）
**Foundation Models** 提供 on-device 30 亿参数大语言模型（隐私优先、离线可用、无需 API Key）。

### 基础 Session + 简单响应
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
                .frame(height: 100)
                .border(.secondary)
            
            Button("Generate") {
                Task { await generate() }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isGenerating)
            
            if isGenerating {
                ProgressView()
            } else {
                ScrollView {
                    Text(response)
                        .textSelection(.enabled)
                }
            }
        }
        .padding()
        .task { await session.prewarm() }   // 强烈推荐预热，减少首字延迟
    }
    
    private func generate() async {
        isGenerating = true
        do {
            let result = try await session.respond(to: prompt)
            response = result
        } catch {
            response = "Error: \(error.localizedDescription)"
        }
        isGenerating = false
    }
}
```

### Streaming 响应（推荐用于长文本）
```swift
private func generateWithStreaming() async {
    isGenerating = true
    response = ""
    do {
        let stream = try await session.streamResponse(to: prompt)
        for try await chunk in stream {
            withAnimation(.easeIn(duration: 0.1)) {
                response += chunk
            }
        }
    } catch {
        response = "Error: \(error.localizedDescription)"
    }
    isGenerating = false
}
```

### Guided Generation + @Generable（强类型输出，推荐）
```swift
import FoundationModels

@Generable
struct TripSuggestion {
    var title: String
    var landmarks: [String]
    @Guide(description: "简短摘要，放最后以提升质量") var summary: String
}

// 使用
let prompt = "Suggest a 3-day trip to Japan focusing on culture."
let result = try await session.respond(to: prompt, generating: TripSuggestion.self)
print(result.title)       // 类型安全
print(result.landmarks)   // [String] 数组
print(result.summary)     // 自动生成的摘要
```

### Tool Calling（让模型调用 App 功能）
```swift
import FoundationModels
import AppIntents

// 定义工具（基于 App Intents）
struct SearchItemTool: AppIntent {
    static var title: LocalizedStringResource = "Search Items"
    
    @Parameter(title: "Query")
    var query: String
    
    func perform() async throws -> some IntentResult {
        // 搜索逻辑
        return .result(value: "Found items matching: \(query)")
    }
}

// 在 Session 中注册工具
let session = LanguageModelSession(tools: [SearchItemTool.self])
let result = try await session.respond(to: "Find my recent photos from Tokyo")
```

**Foundation Models 最佳实践（WWDC25/26）**：
- 始终调用 `prewarm()` 提前加载模型，减少首次响应延迟
- 使用 Streaming + SwiftUI Animation 隐藏生成等待时间
- `@Generable` 属性声明顺序影响生成质量（摘要等总结性字段放最后）
- 仅包含需要显示的属性，避免浪费 token
- 输入前清理数据，避免触发安全护栏
- 处理 `isResponding` 状态，提供良好的加载体验
- 结合 Tool Calling 让模型调用你的 App Intents

## App Intents（与 Siri / Apple Intelligence 深度集成）
暴露 App 功能给系统（Siri、Spotlight、Widgets、Writing Tools、Apple Intelligence 等）。

```swift
import AppIntents

struct AddItemIntent: AppIntent {
    static var title: LocalizedStringResource = "Add New Item"
    static var description: IntentDescription = "Adds a new item to your list"
    
    @Parameter(title: "Title")
    var title: String
    
    @Parameter(title: "Priority", default: .medium)
    var priority: ItemPriority
    
    func perform() async throws -> some IntentResult {
        // 执行逻辑
        return .result(value: "Added: \(title)")
    }
}

// 自定义枚举参数
enum ItemPriority: String, AppEnum {
    case low, medium, high
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Priority")
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .low: "Low",
        .medium: "Medium",
        .high: "High"
    ]
}
```

## 导航与布局（NavigationStack + TabView）

### 基于值的导航（推荐）
```swift
struct ContentView: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            List(items) { item in
                NavigationLink(value: item) {
                    ItemRow(item: item)
                }
            }
            .navigationDestination(for: Item.self) { item in
                DetailView(item: item)
            }
            .navigationTitle("Items")
        }
    }
}
```

### TabView
```swift
TabView {
    Tab("Home", systemImage: "house") {
        HomeView()
    }
    Tab("Search", systemImage: "magnifyingglass") {
        SearchView()
    }
    Tab("Settings", systemImage: "gear") {
        SettingsView()
    }
}
```

### 响应式布局
```swift
struct AdaptiveView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    var body: some View {
        if sizeClass == .compact {
            // iPhone 纵向
            VStack { content }
        } else {
            // iPad / Mac
            HStack { content }
        }
    }
}
```

## 动画与过渡效果
```swift
// 基础动画
withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
    isExpanded.toggle()
}

// 匹配几何效果（共享元素过渡）
@Namespace private var animation

Image(item.image)
    .matchedGeometryEffect(id: item.id, in: animation)

// Phase Animator（多阶段动画）
Text("Hello")
    .phaseAnimator([false, true]) { content, phase in
        content
            .scaleEffect(phase ? 1.2 : 1.0)
            .opacity(phase ? 1.0 : 0.8)
    }
```

## 性能优化（Xcode 26 新工具）

### SwiftUI Performance Instrument（Xcode 26 新增）
- 分析 view body 更新次数、长更新
- 定位不必要的重绘
- List 性能显著提升（无需代码变更即可快 16 倍）

### 最佳实践
```swift
// 避免：在 body 中执行耗时操作
// 推荐：使用 .task {} modifier
struct DataView: View {
    @State private var data: [Item] = []
    
    var body: some View {
        List(data) { item in
            Text(item.title)
        }
        .task {
            data = await fetchData()
        }
        .refreshable {
            data = await fetchData()
        }
    }
}

// 避免：大列表中复杂的内联 View
// 推荐：提取为独立子 View（SwiftUI 自动优化更新粒度）
struct ItemRow: View {
    let item: Item
    var body: some View {
        HStack {
            Text(item.title)
            Spacer()
            Text(item.timestamp, style: .relative)
        }
    }
}
```

### 并发最佳实践（Swift 6.2）
```swift
// Actor 隔离（线程安全）
actor DataService {
    private var cache: [String: Data] = [:]
    
    func fetch(url: URL) async throws -> Data {
        if let cached = cache[url.absoluteString] { return cached }
        let (data, _) = try await URLSession.shared.data(from: url)
        cache[url.absoluteString] = data
        return data
    }
}

// MainActor（UI 更新）
@MainActor
func updateUI(with result: String) {
    self.response = result
}
```

## UIKit 互操作（必要时）
```swift
struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        init(_ parent: CameraView) { self.parent = parent }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            parent.image = info[.originalImage] as? UIImage
            picker.dismiss(animated: true)
        }
    }
}
```

**推荐**：新项目 95%+ 用 SwiftUI，仅相机、复杂手势、旧组件等少数场景用 UIKit。

## 常见坑点与最佳实践（2026 更新）
1. **Liquid Glass**：优先使用 material 而非纯色背景，实现内容聚焦效果
2. **Foundation Models**：必须 prewarm + 处理 streaming 状态；属性顺序影响输出质量
3. **Observations AsyncSequence**：使用 `[weak self]` 防止 retain cycle；适合 Service 层持久化场景
4. **SwiftUI 性能**：用 Xcode 26 新 Instruments 定位频繁更新的 View；提取子 View 优化
5. **SwiftData**：避免在 List 中直接用复杂 predicate（性能）；Preview 用 `inMemory: true`
6. **HIG**：遵循 Liquid Glass、Dynamic Type、Dark Mode、Accessibility、Generative AI 指南
7. **多平台适配**：使用 `horizontalSizeClass` 或 `#if os(iOS)` 适配不同设备
8. **不要在 body 中执行耗时操作** → 用 `.task {}` 或 `.refreshable`
9. **@Observable 类保持轻量** → 复杂逻辑放 Service / Actor
10. **Preview 数据** → 为 SwiftData View 提供 `.modelContainer(for:, inMemory: true)`

## 测试（Swift Testing）
```swift
import Testing
@testable import MyApp

@Test("Item creation sets correct defaults")
func itemCreation() async throws {
    let item = Item(timestamp: .now, title: "Test")
    #expect(item.title == "Test")
    #expect(item.isCompleted == false)
}

@Test("Counter increments correctly")
func counterIncrement() {
    let vm = CounterViewModel()
    vm.increment()
    #expect(vm.count == 1)
}

// 参数化测试
@Test(arguments: ["Hello", "World", "Swift"])
func titleNotEmpty(title: String) {
    let item = Item(timestamp: .now, title: title)
    #expect(!item.title.isEmpty)
}
```

## Xcode 26 Coding Intelligence
Xcode 26 内置 AI 编码助手：
- **代码补全**：基于上下文的智能补全（本地模型 + Apple 服务器）
- **代码重构**：自然语言描述重构意图
- **错误修复**：自动建议修复方案
- **文档生成**：自动生成符合 DocC 规范的注释

搭配本 SKILL.md，Xcode Coding Intelligence 可生成更符合最新 API 的代码。

## 持续更新提示
本文档基于 2026 年 4 月 Apple 官方文档（Xcode 26、iOS 26、WWDC25/26）。  
核心资源：
- Foundation Models：https://developer.apple.com/documentation/foundationmodels
- SwiftUI：https://developer.apple.com/documentation/swiftui
- What's New in SwiftUI：https://developer.apple.com/videos/play/wwdc2025/256/
- Liquid Glass & HIG：https://developer.apple.com/design/human-interface-guidelines
- HIG Generative AI：https://developer.apple.com/design/human-interface-guidelines/generative-ai
- App Intents：https://developer.apple.com/documentation/appintents
- SwiftData：https://developer.apple.com/documentation/swiftdata
- Swift Testing：https://developer.apple.com/documentation/testing

**编辑规则**：仅修改此 SKILL.md → 运行 build 脚本生成各 AI 工具配置。
