---
name: swiftui-development
description: >
  SwiftUI + Swift 6.2 + Xcode 26 + Apple Intelligence 生产级开发知识包（iOS 26+ / iPadOS 26+ / macOS Tahoe 26+ / visionOS 26+）—— 声明式 UI、Liquid Glass、Foundation Models on-device AI、App Intents、SwiftData、WidgetKit、HealthKit、CloudKit、RealityKit、Apple Pay、CoreBluetooth、NaturalLanguage、CoreMotion、AVFoundation、CoreML、Vision、ARKit、CoreImage、SafariServices、EventKit、Contacts、BackgroundTasks、CreateML、SpriteKit、Passkeys、DocumentGroup、Layout 协议、Accessibility、Localization 等 33+ 框架完整覆盖。

  包含 500+ 代码示例、WWDC25/26 最佳实践、常见坑点。专为 Claude Code、Cursor、Xcode Coding Intelligence 等 AI 工具设计。

  Trigger keywords (EN): SwiftUI, Swift 6.2, Xcode 26, Apple Intelligence, Foundation Models, LanguageModelSession, @Generable, Guided Generation, Liquid Glass, glassEffect, GlassEffectContainer, glassEffectID, NavigationStack, zoom transition, @Observable, @Model, SwiftData, Observations AsyncSequence, WebView, Rich TextEditor, WidgetKit, Live Activities, App Intents, AppEntity, EntityQuery, AppShortcuts, HealthKit, CloudKit, RealityKit, RealityView, CoreBluetooth, NaturalLanguage, CoreMotion, Apple Pay, PassKit, Sign in with Apple, Passkeys, StoreKit 2, Xcode Cloud, DocC, Swift Testing, SF Symbols, visionOS, spatial layout, AVFoundation, AVPlayer, AVCaptureSession, CoreML, Vision, VNRecognizeTextRequest, ARKit, CoreImage, CIFilter, SafariServices, ASWebAuthenticationSession, EventKit, Contacts, ContactAccessButton, NWPathMonitor, BackgroundTasks, BGTaskScheduler, CoreData migration, CreateML, SpriteKit, SpriteView, DocumentGroup, FileDocument, Layout protocol, @AppStorage, @SceneStorage, Keychain, Codable, Accessibility, VoiceOver, Localization, Commands, openWindow

  触发关键词（中文）: SwiftUI, Swift 6.2, Xcode 26, 苹果智能, Foundation Models, Liquid Glass, SwiftData, WidgetKit, App Intents, HealthKit, CloudKit, RealityKit, 蓝牙, 自然语言, Apple Pay, Passkeys 无密码登录, StoreKit 内购, 音视频, 相机拍摄, 文字识别 OCR, 人脸检测, AR 增强现实, 图像滤镜, OAuth 登录, 日历提醒, 通讯录, 网络监控, 后台任务, 数据迁移, 机器学习, 2D 游戏, 文档型 App, 多窗口, 菜单命令, 无障碍, 本地化, iOS 26 开发, 多平台适配
---

# SwiftUI Development - Production Knowledge Base（2026 年 4 月完整版）

专注 **iOS 26+ / Swift 6.2 / Xcode 26** 现代应用开发。覆盖 SwiftUI、Apple Intelligence、Liquid Glass、SwiftData、WidgetKit、App Intents、HealthKit、CloudKit、RealityKit、Apple Pay、AVFoundation、CoreML、Vision、ARKit、CoreImage、EventKit、Contacts、Passkeys、BackgroundTasks、SpriteKit、CreateML、DocumentGroup、Layout 协议、Accessibility、Localization 等 **33+ 框架**，58 个章节，500+ 代码示例。

## 平台快照
| 项目 | 值 |
|------|-----|
| OS | iOS 26 / iPadOS 26 / macOS Tahoe 26 / visionOS 26 |
| 语言 | **Swift 6.2**（严格并发 + Observations AsyncSequence） |
| UI 框架 | **SwiftUI** + **Liquid Glass** 设计语言 |
| AI 框架 | **Foundation Models**（on-device LLM，2026.02 更新） |
| 数据持久化 | **SwiftData**（推荐）|
| 状态管理 | **Observation 框架**（@Observable + Observations AsyncSequence） |
| IDE | **Xcode 26**（Coding Intelligence + SwiftUI Performance Instrument） |

## 项目结构
```
MyApp/
├─ MyApp.swift          # @main App 入口
├─ ContentView.swift
├─ Models/              # @Model / @Observable 类
├─ Views/               # SwiftUI Views
├─ Services/            # Network、AI Session、HealthKit 等
├─ Intents/             # App Intents
├─ Widgets/             # WidgetKit Extension
└─ Preview Content/     # Preview 数据
```

## Liquid Glass 设计语言（iOS 26）
Liquid Glass：半透明、折射环境光、动态流体效果。

```swift
// 基础效果
.background(.ultraThinMaterial)
.glassEffect()                         // 边框折射 + 光感
.clipShape(.rect(cornerRadius: 24, style: .continuous))

// 多个效果必须用 GlassEffectContainer（性能关键）
GlassEffectContainer(spacing: 40) {
    HStack(spacing: 40) {
        Image(systemName: "star.fill").glassEffect()
        Text("Featured").glassEffect(.regular.tint(.orange).interactive())
    }
}

// glassEffectID + @Namespace 实现形状 morphing 过渡
@Namespace private var ns
Image("icon")
    .glassEffect()
    .glassEffectID("icon", in: ns)
    .glassEffectTransition(.materialize)  // 或 .matchedGeometry
```

**Toolbar + Liquid Glass**：
```swift
.toolbarBackground(.ultraThinMaterial, for: .navigationBar)
```

**HIG 要点**：多个 glassEffect 必须包在 `GlassEffectContainer` 中，否则性能下降；自动适配 Dark Mode。

## SwiftUI 基础（Swift 6.2）
```swift
@Observable
class CounterViewModel {
    var count = 0
    func increment() { count += 1 }
}

struct CounterView: View {
    @State private var vm = CounterViewModel()
    var body: some View {
        VStack(spacing: 20) {
            Text("Count: \(vm.count)").font(.largeTitle)
            Button("Increment", action: vm.increment).buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Counter")
    }
}
#Preview { NavigationStack { CounterView() } }
```

## 状态管理（Observation 框架）
```swift
// Swift 6.2 Observations AsyncSequence（transactional 快照）
@Observable class ShoppingCart {
    var items: [String] = []
    var total: Decimal = 0
}
let cart = ShoppingCart()

Task {
    for await _ in Observations(of: cart) {
        // 批量同步变更后发出一致快照，适合持久化/日志
        print("Cart: \(cart.items.count) items, \(cart.total)")
    }
}

// 单属性观察
for await newTotal in Observations { cart.total } {
    print("Total: \(newTotal)")
}
```

## SwiftData
```swift
@Model
final class Item {
    @Attribute(.unique) var id: String   // 唯一约束
    var title: String
    var timestamp: Date
    var isCompleted: Bool = false
    var category: Category?

    init(title: String) {
        self.id = UUID().uuidString
        self.title = title
        self.timestamp = .now
    }
}

@Model
final class Category {
    @Attribute(.unique) var name: String
    @Relationship(deleteRule: .cascade, inverse: \Item.category)
    var items: [Item] = []
    init(name: String) { self.name = name }
}

// App 入口
@main struct MyApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
            .modelContainer(for: [Item.self, Category.self])
    }
}

// View 中使用
@Query(sort: \Item.timestamp, order: .reverse) private var items: [Item]
@Environment(\.modelContext) private var context

func addItem(_ title: String) {
    context.insert(Item(title: title))
}

// Preview
#Preview {
    ItemListView()
        .modelContainer(for: Item.self, inMemory: true)
}
```

**SwiftData iOS 26 新特性**：支持模型继承（`@Model class BusinessTrip: Trip {}`）。

## Apple Intelligence & Foundation Models
on-device 30 亿参数 LLM，无需 API Key，隐私安全。

### Context Management
```swift
let model = SystemLanguageModel()
let contextSize = model.contextSize
let tokenCount = try await model.tokenCount(for: prompt)
guard tokenCount < contextSize else { /* 截断或分块 */ return }
```

### Streaming + Liquid Glass UI
```swift
struct AIChatView: View {
    @State private var session = LanguageModelSession()
    @State private var response = ""
    @State private var isGenerating = false

    var body: some View {
        VStack {
            ScrollView {
                Text(response).textSelection(.enabled)
            }
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 20, style: .continuous))

            HStack {
                TextField("Ask AI...", text: $prompt)
                    .textFieldStyle(.roundedBorder)
                Button("Send") { Task { await stream() } }
                    .disabled(isGenerating)
            }
        }
        .task { await session.prewarm() }
    }

    private func stream() async {
        isGenerating = true; response = ""
        do {
            for try await chunk in session.streamResponse(to: prompt) {
                withAnimation(.easeIn(duration: 0.1)) { response += chunk }
            }
        } catch { response = "Error: \(error.localizedDescription)" }
        isGenerating = false
    }
}
```

### Guided Generation（强类型输出）
```swift
@Generable
struct TripSuggestion {
    var title: String
    var landmarks: [String]
    @Guide(description: "简短摘要") var summary: String  // 摘要放最后提升质量
}

let result = try await session.respond(to: prompt, generating: TripSuggestion.self)
```

### Tool Calling
```swift
let session = LanguageModelSession(tools: [SearchItemTool.self])
let result = try await session.respond(to: "Find my Tokyo photos")
```

**最佳实践**：始终 `prewarm()`；`tokenCount + contextSize` 动态管理上下文；属性顺序影响质量；摘要类字段放最后。

## App Intents（Siri / Spotlight / Apple Intelligence）
```swift
// 基础 Intent
struct AddItemIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Item"
    @Parameter(title: "Title") var title: String

    func perform() async throws -> some IntentResult {
        return .result(value: "Added: \(title)")
    }
}

// AppEntity（让系统理解 App 数据）
struct TrailEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Trail"
    static var defaultQuery = TrailEntityQuery()
    var id: String
    var name: String
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct TrailEntityQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [TrailEntity] { [] }
    func suggestedEntities() async throws -> [TrailEntity] { [] }
}

// App Shortcuts（Siri 语音触发）
struct MyShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: AddItemIntent(), phrases: ["Add item to \(.applicationName)"])
    }
}

// Assistant Schemas（Apple Intelligence 深度集成）
@AppIntent(schema: .system.search)
struct SearchIntent: AppIntent { ... }

// Spotlight 索引
CSSearchableIndex.default().indexAppEntities(entities)
```

## WidgetKit（Widget + Live Activities）
```swift
// Timeline Provider
struct GameStatusProvider: TimelineProvider {
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let entry = GameStatusEntry(date: .now, status: "Active")
        let next = Calendar.current.date(byAdding: .minute, value: 15, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
    func placeholder(in context: Context) -> GameStatusEntry { GameStatusEntry(date: .now, status: "—") }
    func getSnapshot(in context: Context, completion: @escaping (GameStatusEntry) -> Void) {
        completion(GameStatusEntry(date: .now, status: "Active"))
    }
}

// 交互式 Widget（iOS 17+）
Button(intent: SuperChargeIntent()) {
    Image(systemName: "bolt.fill")
}

// Smart Stack 相关性
TimelineEntryRelevance(score: 10, duration: 3600)

// 刷新 Widget
WidgetCenter.shared.reloadTimelines(ofKind: "GameStatus")
```

## 导航（NavigationStack + Zoom 过渡 + TabView）
```swift
// Zoom 过渡（iOS 18+，列表→详情的丝滑动画）
@Namespace private var ns

struct ItemList: View {
    var body: some View {
        NavigationStack {
            List(items) { item in
                NavigationLink(value: item) {
                    ItemRow(item: item)
                        .matchedTransitionSource(id: item.id, in: ns)
                }
            }
            .navigationDestination(for: Item.self) { item in
                DetailView(item: item)
                    .navigationTransition(.zoom(sourceID: item.id, in: ns))
            }
        }
    }
}

// TabView（iOS 18+ 新 Tab API）
TabView {
    Tab("Home", systemImage: "house") {
        NavigationStack { HomeView() }
    }
    Tab("Search", systemImage: "magnifyingglass") {
        NavigationStack { SearchView() }
    }
    Tab("Profile", systemImage: "person") {
        NavigationStack { ProfileView() }
    }
}
.tabViewStyle(.tabBarOnly)   // 或 .sidebarAdaptable（iPad 自适应侧栏）

// 编程式切换 Tab
@State private var selectedTab = 0
TabView(selection: $selectedTab) {
    Tab("Home", systemImage: "house", value: 0) { HomeView() }
    Tab("Settings", systemImage: "gear", value: 1) { SettingsView() }
}

// badge
Tab("Inbox", systemImage: "tray") { InboxView() }
    .badge(unreadCount)
```

## 搜索界面
```swift
@State private var searchText = ""
@State private var suggestions = ["Swift", "SwiftUI", "Xcode"]

NavigationStack {
    List(filteredItems) { item in Text(item.name) }
        .searchable(text: $searchText, placement: .navigationBarDrawer, prompt: "Search items") {
            ForEach(suggestions, id: \.self) { s in
                Text(s).searchCompletion(s)
            }
        }
        .navigationTitle("Items")
}

var filteredItems: [Item] {
    searchText.isEmpty ? items : items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
}
```

## 拖拽（Drag & Drop + Transferable）
```swift
// Transferable 协议
extension Contact: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .contact)
        ProxyRepresentation(exportingAs: .plainText) { "\($0.name)" }
    }
}

// 拖拽源
ContactRow(contact: contact).draggable(contact)

// 拖放目标
List { ... }
    .dropDestination(for: Contact.self) { contacts, _ in
        self.contacts.append(contentsOf: contacts)
        return true
    }
```

## 手势
```swift
// @GestureState 临时状态
@GestureState private var isDetecting = false

let longPress = LongPressGesture(minimumDuration: 1)
    .updating($isDetecting) { state, gestureState, _ in gestureState = state }
    .onEnded { _ in print("Long press ended") }

// 拖拽手势
@State private var offset = CGSize.zero
let drag = DragGesture()
    .onChanged { value in offset = value.translation }
    .onEnded { _ in withAnimation { offset = .zero } }

// 手势组合
view.gesture(longPress.simultaneously(with: drag))
```

## 动画
```swift
// 弹簧动画
withAnimation(.spring(duration: 0.5, bounce: 0.3)) { isExpanded.toggle() }

// 多阶段 Phase Animator
Text("Hello").phaseAnimator([false, true]) { content, phase in
    content.scaleEffect(phase ? 1.2 : 1.0).opacity(phase ? 1.0 : 0.8)
}

// 共享元素 matchedGeometryEffect
@Namespace private var animation
Image(item.image).matchedGeometryEffect(id: item.id, in: animation)
```

## HealthKit
```swift
let healthStore = HKHealthStore()

// 请求权限
let readTypes: Set<HKSampleType> = [
    HKObjectType.quantityType(forIdentifier: .heartRate)!,
    HKObjectType.quantityType(forIdentifier: .stepCount)!
]
try await healthStore.requestAuthorization(toShare: [], read: readTypes)

// 查询数据
let query = HKSampleQuery(
    sampleType: HKObjectType.quantityType(forIdentifier: .heartRate)!,
    predicate: nil, limit: 100,
    sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
) { _, samples, _ in
    DispatchQueue.main.async {
        guard let samples = samples as? [HKQuantitySample] else { return }
        self.heartRates = samples.map { $0.quantity.doubleValue(for: .init(from: "count/min")) }
    }
}
healthStore.execute(query)

// 后台交付（数据变化时唤醒 App）
healthStore.enableBackgroundDelivery(for: heartRateType, frequency: .immediate) { _, _ in }
```

## CloudKit
```swift
let container = CKContainer.default()
let db = container.privateCloudDatabase

// 保存记录
let record = CKRecord(recordType: "TodoItem")
record["title"] = "Buy groceries"
record["dueDate"] = Date()
// 加密字段（iOS 15+）
record.encryptedValues["sensitiveNote"] = "Private content"

db.save(record) { _, error in
    if let error { print("Save error: \(error)") }
}

// 查询
let predicate = NSPredicate(value: true)
let query = CKQuery(recordType: "TodoItem", predicate: predicate)
let (results, _) = try await db.records(matching: query)

// CloudKit + SwiftData 同步：.modelContainer 设置 cloudKitContainerIdentifier
.modelContainer(for: Item.self, configurations: [
    ModelConfiguration(cloudKitDatabase: .automatic)
])
```

**注意**：Schema 一旦部署到生产只能新增，不能删除字段；加密字段不支持 CKAsset。

## Sign in with Apple
```swift
import AuthenticationServices

struct SignInView: View {
    var body: some View {
        SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [.fullName, .email]
        } onCompletion: { result in
            switch result {
            case .success(let auth):
                if let credential = auth.credential as? ASAuthorizationAppleIDCredential {
                    let userID = credential.user
                    let email = credential.email
                    // 存入 Keychain
                }
            case .failure(let error):
                print("Auth failed: \(error)")
            }
        }
        .signInWithAppleButtonStyle(.black)
        .frame(height: 50)
    }
}
```

## Push Notifications
```swift
// 请求权限
let center = UNUserNotificationCenter.current()
try await center.requestAuthorization(options: [.alert, .sound, .badge])

// 本地通知
let content = UNMutableNotificationContent()
content.title = "Reminder"
content.body = "Time to check in!"
content.sound = .default

let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
try await center.add(request)

// 前台展示
func userNotificationCenter(_ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler handler: @escaping (UNNotificationPresentationOptions) -> Void) {
    handler([.banner, .sound, .badge])
}
```

## Apple Pay（PassKit）
```swift
import PassKit

// 检查是否支持
guard PKPaymentAuthorizationController.canMakePayments() else { return }

let request = PKPaymentRequest()
request.merchantIdentifier = "merchant.com.example.app"
request.supportedNetworks = [.visa, .masterCard, .amex]
request.merchantCapabilities = .capability3DS
request.countryCode = "CN"
request.currencyCode = "CNY"
request.paymentSummaryItems = [
    PKPaymentSummaryItem(label: "Pro Subscription", amount: NSDecimalNumber(string: "68.00"))
]

let controller = PKPaymentAuthorizationController(paymentRequest: request)
controller.delegate = self
controller.present()

// 授权完成
func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController,
    didAuthorizePayment payment: PKPayment,
    handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
    // 发送 payment.token 到服务器验证
    completion(PKPaymentAuthorizationResult(status: .success))
}
```

## NaturalLanguage
```swift
import NaturalLanguage

// 语言识别
let recognizer = NLLanguageRecognizer()
recognizer.processString("Hello, SwiftUI world!")
print(recognizer.dominantLanguage?.rawValue ?? "unknown")  // "en"

// 词性标注
let tagger = NLTagger(tagSchemes: [.lexicalClass])
tagger.string = "Apple ships Swift 6."
tagger.enumerateTags(in: tagger.string!.startIndex..., unit: .word,
    scheme: .lexicalClass, options: [.omitPunctuation, .omitWhitespace]) { tag, range in
    print("\(tagger.string![range]): \(tag?.rawValue ?? "")")
    return true
}

// 命名实体识别
let nerTagger = NLTagger(tagSchemes: [.nameType])
// 识别 .personalName / .placeName / .organizationName

// 语义相似度（词嵌入）
if let embedding = NLEmbedding.wordEmbedding(for: .english) {
    let distance = embedding.distance(between: "bicycle", and: "motorcycle")
    // distance 越小越相似
}
```

## CoreMotion
```swift
import CoreMotion

class MotionManager: ObservableObject {
    private let manager = CMMotionManager()
    @Published var pitch: Double = 0
    @Published var roll: Double = 0

    func start() {
        guard manager.isDeviceMotionAvailable else { return }
        manager.deviceMotionUpdateInterval = 1.0 / 60.0
        manager.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
            guard let data else { return }
            self?.pitch = data.attitude.pitch
            self?.roll = data.attitude.roll
        }
    }

    func stop() { manager.stopDeviceMotionUpdates() }
}

// 计步器
let pedometer = CMPedometer()
if CMPedometer.isStepCountingAvailable() {
    pedometer.startUpdates(from: .now) { data, _ in
        guard let data else { return }
        print("Steps: \(data.numberOfSteps)")
    }
}
```
**注意**：visionOS 中 motion 数据只在 immersive space 开启时可用；用完立即停止以节省电量。

## CoreBluetooth（BLE）
```swift
import CoreBluetooth

class BLEManager: NSObject, CBCentralManagerDelegate, ObservableObject {
    private var centralManager: CBCentralManager!
    @Published var discoveredDevices: [CBPeripheral] = []

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: [myServiceUUID],
                options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        guard RSSI.intValue >= -50 else { return }  // 信号强度过滤
        discoveredDevices.append(peripheral)
        central.connect(peripheral)
    }
}

// 外设（Peripheral）模式
let characteristic = CBMutableCharacteristic(
    type: myCharacteristicUUID,
    properties: [.notify, .writeWithoutResponse],
    value: nil, permissions: [.readable, .writeable]
)
```

## RealityKit（AR / visionOS）
```swift
import RealityKit
import SwiftUI

// RealityView（iOS 18+ / visionOS）
struct ARSceneView: View {
    @State private var entity: ModelEntity?

    var body: some View {
        RealityView { content in
            // 加载 3D 模型
            if let model = try? await ModelEntity(named: "robot.usdz") {
                model.generateCollisionShapes(recursive: true)
                content.add(model)
                entity = model
            }
        } update: { content in
            entity?.transform.rotation = simd_quatf(angle: .pi, axis: [0, 1, 0])
        }
        .gesture(TapGesture().targetedToAnyEntity().onEnded { _ in
            entity?.model?.materials = [SimpleMaterial(color: .orange, isMetallic: true)]
        })
    }
}

// ECS（Entity Component System）
struct RotationComponent: Component { var speed: Float = 1.0 }

class RotationSystem: System {
    static let query = EntityQuery(where: .has(RotationComponent.self))
    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            let speed = entity.components[RotationComponent.self]?.speed ?? 1
            entity.setOrientation(
                simd_quatf(angle: speed * Float(context.deltaTime), axis: [0,1,0]),
                relativeTo: entity)
        }
    }
}

// PBR 材质
var material = PhysicallyBasedMaterial()
material.baseColor.tint = .systemBlue
material.roughness = .init(floatLiteral: 0.3)
material.metallic = .init(floatLiteral: 0.8)
```

## WebKit（WKWebView 集成）
```swift
import WebKit
import SwiftUI

struct WebView: UIViewRepresentable {
    let url: URL
    var onNavigate: ((URL) -> Void)?

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.load(URLRequest(url: url))
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebView
        init(_ parent: WebView) { self.parent = parent }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if let url = webView.url { parent.onNavigate?(url) }
        }
    }
}
```

## StoreKit 2（内购 / 订阅）
```swift
import StoreKit

// 加载商品
let products = try await Product.products(for: ["com.app.pro.monthly"])

// 购买
let result = try await products.first?.purchase()
switch result {
case .success(let verification):
    let transaction = try verification.payloadValue
    await transaction.finish()
case .userCancelled, .pending: break
default: break
}

// 验证当前权益
for await result in Transaction.currentEntitlements {
    if case .verified(let transaction) = result {
        // 激活对应功能
        print("Entitled: \(transaction.productID)")
    }
}

// 监听交易更新
for await result in Transaction.updates {
    if case .verified(let transaction) = result {
        await transaction.finish()
    }
}

// 恢复购买
try await AppStore.sync()
```

## URLSession（现代网络请求）
```swift
// async/await 方式（推荐）
func fetchData<T: Decodable>(from url: URL, as type: T.Type) async throws -> T {
    let (data, response) = try await URLSession.shared.data(from: url)
    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode) else {
        throw URLError(.badServerResponse)
    }
    return try JSONDecoder().decode(T.self, from: data)
}

// 带进度的下载
private lazy var session: URLSession = {
    let config = URLSessionConfiguration.default
    config.waitsForConnectivity = true
    return URLSession(configuration: config, delegate: self, delegateQueue: nil)
}()

// 后台下载
let bgConfig = URLSessionConfiguration.background(withIdentifier: "com.app.download")
bgConfig.sessionSendsLaunchEvents = true
let bgSession = URLSession(configuration: bgConfig, delegate: self, delegateQueue: nil)
```

## CoreLocation + MapKit
```swift
// CoreLocation（async 方式，iOS 17+）
@MainActor class LocationManager: ObservableObject {
    @Published var location: CLLocation?
    private let manager = CLLocationManager()

    func start() {
        manager.requestWhenInUseAuthorization()
        Task {
            for try await update in CLLocationUpdate.liveUpdates() {
                location = update.location
            }
        }
    }
}

// SwiftUI Map
import MapKit
struct MapView: View {
    var body: some View {
        Map(initialPosition: .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 39.9, longitude: 116.4),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )))
    }
}
```

## 性能优化（Xcode 26）
```swift
// LazyVStack：仅在 100+ 元素且 profiling 证明需要时使用
ScrollView {
    LazyVStack {
        ForEach(largeData) { item in ItemRow(item: item) }
    }
}

// 提取子 View（SwiftUI 细粒度更新）
struct ItemRow: View {
    let item: Item  // let 防止不必要更新
    var body: some View {
        HStack {
            Text(item.title)
            Spacer()
            Text(item.timestamp, style: .relative)
        }
    }
}

// .task 替代 onAppear
.task { data = await fetchData() }
.refreshable { data = await fetchData() }

// Actor（线程安全缓存）
actor DataCache {
    private var cache: [String: Data] = [:]
    func get(_ key: String) -> Data? { cache[key] }
    func set(_ key: String, value: Data) { cache[key] = value }
}
```

**Xcode 26 SwiftUI Performance Instrument**：打开 Instruments → SwiftUI 模板 → 查看 View Body Updates 和 Timeline，定位频繁重绘。

## UIKit 互操作
```swift
struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ vc: UIImagePickerController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        init(_ p: CameraView) { self.parent = p }
        func imagePickerController(_ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            parent.image = info[.originalImage] as? UIImage
            picker.dismiss(animated: true)
        }
    }
}
```

## SwiftUI 新特性（iOS 26 / WWDC25）
```swift
// WebView（原生，无需 UIViewRepresentable）
WebView(url: URL(string: "https://developer.apple.com")!)

// Rich TextEditor
@State private var text = AttributedString("Hello **SwiftUI**!")
RichTextEditor($text).padding()

// Section Index Titles
List { ... }.sectionIndexTitles(sections.map(\.title))

// visionOS Spatial Layout
WindowGroup { ContentView() }.windowStyle(.volumetric)
ImmersiveSpace(id: "main") { ImmersiveView() }
```

## Xcode 工具
**DocC 注释**：
```swift
/// 简短描述。
///
/// 详细说明。
/// - Parameters:
///   - input: 输入说明
/// - Returns: 返回值说明
/// - Throws: 错误类型
func process(_ input: String) throws -> Result
```

**Xcode Cloud**：在 Xcode → Product → Xcode Cloud 配置 CI/CD 工作流（Build / Test / Archive），支持 PR 触发、多设备测试、TestFlight 自动分发。

## 测试（Swift Testing）
```swift
import Testing
@testable import MyApp

@Test("创建 Item 默认值正确")
func itemDefaults() {
    let item = Item(title: "Test")
    #expect(item.isCompleted == false)
    #expect(!item.id.isEmpty)
}

// 参数化测试
@Test(arguments: ["Swift", "SwiftUI", "Xcode"])
func titleNotEmpty(title: String) {
    #expect(!Item(title: title).title.isEmpty)
}

// async 测试
@Test func fetchData() async throws {
    let data = try await DataService().fetch(url: testURL)
    #expect(!data.isEmpty)
}
```


## AVFoundation（音视频）

### 视频播放
```swift
import AVKit

struct VideoView: View {
    @State private var player = AVPlayer(url: Bundle.main.url(forResource: "demo", withExtension: "mp4")!)
    var body: some View {
        VideoPlayer(player: player)
            .frame(height: 300)
            .onAppear { player.play() }
            .onDisappear { player.pause() }
    }
}
```

### 相机拍摄（AVCaptureSession，用 actor 隔离）
```swift
actor CaptureService {
    private let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()

    func setUp() throws {
        let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)!
        let input = try AVCaptureDeviceInput(device: device)
        session.sessionPreset = .photo
        if session.canAddInput(input) { session.addInput(input) }
        if session.canAddOutput(photoOutput) { session.addOutput(photoOutput) }
        session.startRunning()
    }
}

// 相机权限
var isAuthorized: Bool {
    get async {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .notDetermined {
            return await AVCaptureDevice.requestAccess(for: .video)
        }
        return status == .authorized
    }
}

// SwiftUI 预览层
struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = view.bounds
        view.layer.addSublayer(layer)
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
}
```

### 文字转语音
```swift
let utterance = AVSpeechUtterance(string: "Hello, SwiftUI!")
utterance.rate = 0.57
utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
AVSpeechSynthesizer().speak(utterance)
```

## CoreML + Vision

### CoreML 推理
```swift
import CoreML

// 编译并缓存模型（下载后执行一次）
let compiledURL = try await MLModel.compileModel(at: downloadedModelURL)
let model = try MLModel(contentsOf: compiledURL)
let prediction = try model.prediction(from: input)
```

### Vision 文字识别（OCR）
```swift
import Vision

func recognizeText(in image: UIImage) async throws -> [String] {
    guard let cgImage = image.cgImage else { return [] }
    return try await withCheckedThrowingContinuation { continuation in
        let request = VNRecognizeTextRequest { req, error in
            if let error { continuation.resume(throwing: error); return }
            let strings = (req.results as? [VNRecognizedTextObservation] ?? [])
                .compactMap { $0.topCandidates(1).first?.string }
            continuation.resume(returning: strings)
        }
        request.recognitionLevel = .accurate
        try? VNImageRequestHandler(cgImage: cgImage).perform([request])
    }
}
```

### Vision 人脸检测
```swift
let request = VNDetectFaceRectanglesRequest { req, _ in
    guard let faces = req.results as? [VNFaceObservation] else { return }
    for face in faces {
        print("Face bounding box: \(face.boundingBox)")
    }
}
try VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up).perform([request])
```

### Vision + CoreML（图像分类）
```swift
let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
let request = VNCoreMLRequest(model: visionModel) { req, _ in
    guard let results = req.results as? [VNRecognizedObjectObservation] else { return }
    let top = results.first?.labels.first
    print("\(top?.identifier ?? "unknown") (\(top?.confidence ?? 0))")
}
try VNImageRequestHandler(cgImage: cgImage).perform([request])
```

## ARKit
```swift
import ARKit
import RealityKit

// 基础世界追踪 + 平面检测
let config = ARWorldTrackingConfiguration()
config.planeDetection = [.horizontal, .vertical]
config.environmentTexturing = .automatic
arView.session.run(config)

// 协同 AR（多人共享空间）
config.isCollaborationEnabled = true
func session(_ session: ARSession, didOutputCollaborationData data: ARSession.CollaborationData) {
    let encoded = try? NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: true)
    multipeerSession.sendToAllPeers(encoded, reliably: data.priority == .critical)
}

// 面部追踪（前置摄像头）
guard ARWorldTrackingConfiguration.supportsUserFaceTracking else { return }
var faceConfig = ARWorldTrackingConfiguration()
faceConfig.userFaceTrackingEnabled = true
// 读取混合形状（表情驱动）
let blendShapes = faceAnchor.blendShapes
let eyeBlink = blendShapes[.eyeBlinkLeft] as? Float ?? 0
```

## CoreImage（图像处理）
```swift
import CoreImage.CIFilterBuiltins

// CIContext 创建一次，全局复用（昂贵操作）
let ciContext = CIContext()

// 滤镜链（自动合并优化）
func applyFilters(to image: UIImage) -> UIImage? {
    guard let ciImage = CIImage(image: image) else { return nil }

    let sepia = CIFilter.sepiaTone()
    sepia.inputImage = ciImage
    sepia.intensity = 0.9

    let bloom = CIFilter.bloom()
    bloom.inputImage = sepia.outputImage
    bloom.intensity = 1.0
    bloom.radius = 10

    guard let output = bloom.outputImage,
          let cgImage = ciContext.createCGImage(output, from: output.extent) else { return nil }
    return UIImage(cgImage: cgImage)
}

// SwiftUI Canvas 自定义绘制
Canvas { context, size in
    context.fill(Path(ellipseIn: CGRect(origin: .zero, size: size)), with: .color(.blue))
    context.stroke(Path { p in p.move(to: .zero); p.addLine(to: CGPoint(x: size.width, y: size.height)) },
                   with: .color(.red), lineWidth: 2)
}
```

## SafariServices + OAuth
```swift
import SafariServices
import AuthenticationServices

// SFSafariViewController（保持用户 cookie/session）
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
    func updateUIViewController(_ vc: SFSafariViewController, context: Context) {}
}

// ASWebAuthenticationSession（OAuth 登录）
func startOAuth() {
    let authURL = URL(string: "https://provider.com/oauth/authorize?client_id=xxx")!
    let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: "myapp") { url, error in
        guard let url else { return }
        // 从 url 提取 code，换取 token
    }
    session.presentationContextProvider = self
    session.prefersEphemeralWebBrowserSession = true
    session.start()
}
```

## EventKit（日历 / 提醒）
```swift
import EventKit

let eventStore = EKEventStore()

// iOS 17+ 三种权限级别
func requestCalendarAccess() async throws {
    // 写入权限（低打扰）
    try await eventStore.requestWriteOnlyAccessToEvents()
}

// 创建事件
func createEvent(title: String, start: Date, end: Date) throws {
    let event = EKEvent(eventStore: eventStore)
    event.calendar = eventStore.defaultCalendarForNewEvents
    event.title = title
    event.startDate = start
    event.endDate = end
    try eventStore.save(event, span: .thisEvent)
}

// 监听日历变更
for await _ in NotificationCenter.default.notifications(named: .EKEventStoreChanged) {
    // 重新获取事件
}
```

## Contacts（通讯录）
```swift
import Contacts
import ContactsUI

// iOS 18+ ContactAccessButton（无需完整权限）
ContactAccessButton(queryString: searchText) { identifiers in
    // 用户选择的联系人 identifier
}

// 获取联系人
func fetchContacts() throws -> [CNContact] {
    let store = CNContactStore()
    let request = CNContactFetchRequest(keysToFetch: [
        CNContactGivenNameKey as CNKeyDescriptor,
        CNContactFamilyNameKey as CNKeyDescriptor,
        CNContactEmailAddressesKey as CNKeyDescriptor
    ] as [CNKeyDescriptor])
    var contacts: [CNContact] = []
    try store.enumerateContacts(with: request) { contact, _ in contacts.append(contact) }
    return contacts
}
```

## Network（连接监控）
```swift
import Network

// 网络状态监控
let monitor = NWPathMonitor()
monitor.pathUpdateHandler = { path in
    DispatchQueue.main.async {
        let isConnected = path.status == .satisfied
        let isWifi = path.usesInterfaceType(.wifi)
        let isCellular = path.usesInterfaceType(.cellular)
    }
}
monitor.start(queue: .global(qos: .background))

// 不需要时取消
// monitor.cancel()
```

## BackgroundTasks
```swift
import BackgroundTasks

// 注册（在 App init 或 didFinishLaunching 中调用）
BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.app.refresh", using: nil) { task in
    guard let task = task as? BGAppRefreshTask else { return }
    Task {
        do {
            try await refreshContent()
            task.setTaskCompleted(success: true)
        } catch {
            task.setTaskCompleted(success: false)
        }
    }
    task.expirationHandler = { task.setTaskCompleted(success: false) }
}

// 调度刷新
func scheduleAppRefresh() throws {
    let request = BGAppRefreshTaskRequest(identifier: "com.app.refresh")
    request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
    try BGTaskScheduler.shared.submit(request)
}

// 长任务（带进度显示）
let continuedRequest = BGContinuedProcessingTaskRequest(
    identifier: "com.app.export",
    title: "Exporting",
    subtitle: "Starting..."
)
try BGTaskScheduler.shared.submit(continuedRequest)

// Xcode 调试命令
// e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.app.refresh"]
```

## CoreData → SwiftData 迁移
```swift
// 共存：两个框架操作同一个 SQLite 文件
// CoreData 端：开启持久历史追踪
if let desc = container.persistentStoreDescriptions.first {
    desc.url = sharedStoreURL
    desc.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
}

// SwiftData 端：指向同一 URL
let modelConfig = ModelConfiguration(url: sharedStoreURL)
let modelContainer = try ModelContainer(for: Trip.self, configurations: modelConfig)

// 检测 Widget 写入的变更
func findWidgetTransactions(after token: DefaultHistoryToken?) -> [DefaultHistoryTransaction] {
    var desc = HistoryDescriptor<DefaultHistoryTransaction>()
    if let token { desc.token = token }
    desc.predicate = #Predicate { $0.author == "widget" }
    return (try? modelContext.fetchHistory(desc)) ?? []
}
```

## CreateML（训练本地模型）
```swift
import CreateML

// 图像分类器
let trainingData = try MLImageClassifier.DataSource.labeledImages(fromDirectory: trainURL)
let classifier = try MLImageClassifier(
    trainingData: trainingData,
    parameters: MLImageClassifier.ModelParameters(
        augmentationOptions: .all,
        algorithm: .transferLearning(.mobilenet)
    )
)
try classifier.write(to: outputURL, metadata: MLModelMetadata(author: "MyApp", version: "1.0"))

// 文本分类器
let textClassifier = try MLTextClassifier(
    trainingData: trainingData,
    textColumn: "text",
    labelColumn: "label",
    parameters: .init(algorithm: .transferLearning(.bertEmbedding, revision: 1), language: .english)
)
// 导出后在 App 中用 NLModel 包装使用
let nlModel = try NLModel(mlModel: textClassifier.model)
print(nlModel.predictedLabel(for: "This is great!") ?? "unknown")
```


## Foundation 常用模式

### @AppStorage / UserDefaults
```swift
// @AppStorage 自动绑定 UserDefaults
@AppStorage("username") var username = ""
@AppStorage("isDarkMode") var isDarkMode = false

// 手动访问
UserDefaults.standard.set(true, forKey: "onboarded")
let onboarded = UserDefaults.standard.bool(forKey: "onboarded")

// 注册默认值（App 启动时调用）
UserDefaults.standard.register(defaults: [
    "theme": "light",
    "fontSize": 16
])
```

### Keychain（安全存储凭证）
```swift
import Security

func saveToKeychain(key: String, value: String) {
    let data = value.data(using: .utf8)!
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: key,
        kSecValueData as String: data,
        kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
    ]
    SecItemDelete(query as CFDictionary)  // 先删除旧值
    SecItemAdd(query as CFDictionary, nil)
}

func loadFromKeychain(key: String) -> String? {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: key,
        kSecReturnData as String: true
    ]
    var result: CFTypeRef?
    guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
          let data = result as? Data else { return nil }
    return String(data: data, encoding: .utf8)
}
```

### Codable / JSONDecoder
```swift
struct User: Codable {
    let id: Int
    let name: String
    let email: String
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, name, email
        case createdAt = "created_at"  // 映射 snake_case
    }
}

let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .iso8601
decoder.keyDecodingStrategy = .convertFromSnakeCase  // 自动转换

let user = try decoder.decode(User.self, from: jsonData)

let encoder = JSONEncoder()
encoder.keyEncodingStrategy = .convertToSnakeCase
let data = try encoder.encode(user)
```

### FileManager
```swift
// 获取 Documents 目录
let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
let fileURL = docs.appendingPathComponent("data.json")

// 写入 / 读取
try data.write(to: fileURL, options: .atomic)
let loaded = try Data(contentsOf: fileURL)

// APFS 零拷贝克隆
try FileManager.default.copyItem(at: sourceURL, to: destURL)

// 检查磁盘空间
let attributes = try FileManager.default.attributesOfFileSystem(forPath: docs.path)
let freeSpace = attributes[.systemFreeSize] as? Int64 ?? 0
```

## Accessibility（无障碍）
```swift
// 基础标签、值、提示
Image(systemName: "heart.fill")
    .accessibilityLabel("Favorite")
    .accessibilityAddTraits(.isButton)

Text("\(score)")
    .accessibilityLabel("Score: \(score)")
    .accessibilityValue("\(score) points")
    .accessibilityHint("Double tap to reset")

// 自定义操作
view.accessibilityAction(named: "Delete") { deleteItem() }

// 焦点管理（VoiceOver 自动聚焦）
@AccessibilityFocusState private var focused: Bool
Button("Submit") { focused = true }
    .accessibilityFocused($focused)

// 合并子视图（把卡片作为整体播报）
VStack { ... }.accessibilityElement(children: .combine)

// 动态字体支持（自动，无需额外代码）
Text("Title").font(.headline)  // 随系统字体大小缩放
```

## Custom Layout（Layout 协议）
```swift
struct RadialLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let radius = min(bounds.width, bounds.height) / 2
        let angle = (2 * Double.pi) / Double(subviews.count)
        for (index, subview) in subviews.enumerated() {
            let x = bounds.midX + radius * cos(Double(index) * angle)
            let y = bounds.midY + radius * sin(Double(index) * angle)
            subview.place(at: CGPoint(x: x, y: y), anchor: .center, proposal: .unspecified)
        }
    }
}

// 使用
RadialLayout {
    ForEach(items) { item in Circle().fill(item.color).frame(width: 30) }
}

// ViewThatFits：自动选择合适的布局变体
ViewThatFits {
    HStack { content }   // 优先尝试横排
    VStack { content }   // 不够宽则降级竖排
}
```

## 文档型 App（DocumentGroup）
```swift
import UniformTypeIdentifiers

extension UTType {
    static let myDocument = UTType(exportedAs: "com.example.mydoc")
}

struct MyDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.myDocument, .plainText] }
    var text: String = ""

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        text = string
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        .init(regularFileWithContents: Data(text.utf8))
    }
}

@main
struct WritingApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: MyDocument()) { file in
            EditorView(document: file.$document)
        }
    }
}
```

## 多窗口 + 状态恢复
```swift
// 多窗口（iPad / macOS）
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }

        // 以数据值驱动的辅助窗口
        WindowGroup("Detail", for: Item.ID.self) { $id in
            DetailView(itemID: id)
        }
    }
}

// 打开辅助窗口
@Environment(\.openWindow) private var openWindow
Button("Open Detail") { openWindow(value: item.id) }

// @SceneStorage：每个 scene 独立持久化
@SceneStorage("selectedTab") private var selectedTab = 0
@SceneStorage("scrollPosition") private var position: String?

// Handoff / NSUserActivity
.userActivity("com.app.viewItem") { activity in
    activity.typedPayload = selectedItem
} onContinue: { activity in
    selectedItem = try? activity.typedPayload(Item.self)
}
```

## macOS 菜单命令（Commands）
```swift
// 定义命令
struct AppCommands: Commands {
    @FocusedValue(DataModel.self) private var model: DataModel?

    var body: some Commands {
        CommandGroup(after: .newItem) {
            Button("New Message") { model?.addMessage() }
                .keyboardShortcut("m", modifiers: [.command, .shift])
                .disabled(model == nil)
        }
        CommandMenu("Tools") {
            Button("Export") { model?.export() }
            Divider()
            Toggle("Show Inspector", isOn: $showInspector)
        }
    }
}

// 注册到 App
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup { ContentView().focusedSceneValue(dataModel) }
            .commands { AppCommands() }
    }
}
```

## Passkeys（无密码登录）
```swift
import AuthenticationServices

// 注册 Passkey
func registerPasskey(for username: String, challengeData: Data) {
    let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(
        relyingPartyIdentifier: "example.com"
    )
    let request = provider.createCredentialRegistrationRequest(
        clientDataHash: challengeData,
        name: username,
        userID: Data(username.utf8)
    )
    let controller = ASAuthorizationController(authorizationRequests: [request])
    controller.delegate = self
    controller.performRequests()
}

// 验证 Passkey
func authenticateWithPasskey(challengeData: Data) {
    let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(
        relyingPartyIdentifier: "example.com"
    )
    let assertionRequest = provider.createCredentialAssertionRequest(
        clientDataHash: challengeData
    )
    let controller = ASAuthorizationController(authorizationRequests: [assertionRequest])
    controller.delegate = self
    controller.performRequests()
}

// 委托回调
func authorizationController(controller: ASAuthorizationController,
    didCompleteWithAuthorization authorization: ASAuthorization) {
    if let credential = authorization.credential
        as? ASAuthorizationPlatformPublicKeyCredentialAssertion {
        // 发送 credential.rawAuthenticatorData 到服务器验证
    }
}
```

## 本地化（Localization）
```swift
// 推荐：String(localized:) 带 comment
let title = String(localized: "Welcome", comment: "App welcome screen title")

// SwiftUI 自动识别 LocalizedStringKey
Text("Add Item")  // 自动查找 Localizable.strings

// 数字 / 货币 / 日期格式化（自动本地化）
Text(price.formatted(.currency(code: "USD")))
Text(date.formatted(.dateTime.year().month().day()))
Text(count.formatted(.number))

// 复数规则（.stringsdict 或内联 inflection）
Button("Add ^[\(count) item](inflect: true)") { }
// 中文：需在 Localizable.stringsdict 配置 NSStringLocalizedFormatKey

// 支持从右到左（RTL）布局
// SwiftUI 自动处理，避免使用 .leading/.trailing，改用 .leading（语义化）
HStack { ... }  // 自动翻转 RTL
```

## SpriteKit（2D 游戏）
```swift
import SpriteKit
import SwiftUI

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = .black
        physicsWorld.gravity = CGVector(dx: 0, dy: -5)

        let sprite = SKSpriteNode(imageNamed: "player")
        sprite.position = CGPoint(x: frame.midX, y: frame.midY)
        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        sprite.physicsBody?.isDynamic = true
        addChild(sprite)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let moveAction = SKAction.move(to: location, duration: 0.5)
        children.first?.run(moveAction)
    }

    override func update(_ currentTime: TimeInterval) { /* 每帧逻辑 */ }
}

// 在 SwiftUI 中嵌入
struct GameView: View {
    var scene: SKScene {
        let s = GameScene()
        s.scaleMode = .resizeFill
        return s
    }
    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}
```


## SwiftUI 进阶模式

### @Bindable（iOS 17+，Observable 模型绑定）
```swift
@Observable class Recipe {
    var name = ""
    var rating = 0
}

struct RecipeEditor: View {
    @Bindable var recipe: Recipe   // 直接投射 $binding
    var body: some View {
        TextField("Name", text: $recipe.name)
        Stepper("Rating: \(recipe.rating)", value: $recipe.rating, in: 0...5)
    }
}
```

### AnyLayout（运行时切换布局，带动画）
```swift
let layout = isGrid ? AnyLayout(HStackLayout()) : AnyLayout(VStackLayout())

layout {
    ForEach(items) { item in ItemView(item: item) }
}
.animation(.default, value: isGrid)  // 布局切换自动动画
```

### KeyframeAnimator（多轨道关键帧动画）
```swift
struct AnimationValues {
    var scale = 1.0
    var yOffset = 0.0
    var angle = Angle.zero
}

Text("🎉")
    .keyframeAnimator(initialValue: AnimationValues(), trigger: trigger) { content, value in
        content
            .scaleEffect(value.scale)
            .offset(y: value.yOffset)
            .rotationEffect(value.angle)
    } keyframes: { _ in
        KeyframeTrack(\.scale) {
            SpringKeyframe(1.5, duration: 0.4, spring: .bouncy)
            SpringKeyframe(1.0, spring: .bouncy)
        }
        KeyframeTrack(\.yOffset) {
            LinearKeyframe(-60, duration: 0.2)
            SpringKeyframe(0, duration: 0.6, spring: .bouncy)
        }
        KeyframeTrack(\.angle) {
            LinearKeyframe(.degrees(15), duration: 0.2)
            SpringKeyframe(.zero, spring: .bouncy)
        }
    }
```

### AsyncImage（异步加载远程图片）
```swift
AsyncImage(url: URL(string: "https://example.com/photo.jpg")) { phase in
    switch phase {
    case .empty: ProgressView()
    case .success(let image):
        image.resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 200, height: 200)
            .clipped()
    case .failure: Image(systemName: "photo").foregroundStyle(.secondary)
    @unknown default: EmptyView()
    }
}

// 图片缩放模式
Image("photo")
    .resizable()
    .aspectRatio(contentMode: .fit)    // 完整显示，可能留白
    .frame(width: 300, height: 200)

Image("photo")
    .resizable()
    .aspectRatio(contentMode: .fill)   // 填满，可能裁切
    .frame(width: 300, height: 200)
    .clipped()                          // 必须加 clipped 防溢出
```

### onChange（监听值变化）
```swift
@State private var searchText = ""

TextField("Search", text: $searchText)
    .onChange(of: searchText) { oldValue, newValue in   // iOS 17+ 双参数
        filterResults(query: newValue)
    }
```

### PreferenceKey（子视图向父视图传数据）
```swift
struct HeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// 子视图上报高度
ChildView()
    .background(GeometryReader { geo in
        Color.clear.preference(key: HeightKey.self, value: geo.size.height)
    })

// 父视图接收
.onPreferenceChange(HeightKey.self) { height in
    containerHeight = height
}
```

### Table（macOS / iPadOS 多列表格）
```swift
@State private var sortOrder = [KeyPathComparator(\Person.name)]

Table(people, selection: $selectedID, sortOrder: $sortOrder) {
    TableColumn("Name", value: \.name)
    TableColumn("Age", value: \.age) { Text("\($0.age)") }
    TableColumn("Email", value: \.email)
}
.onChange(of: sortOrder) { _, newOrder in
    people.sort(using: newOrder)
}
```

### AttributedString（富文本渲染）
```swift
var styled: AttributedString {
    var str = AttributedString("Welcome to ")
    var bold = AttributedString("SwiftUI")
    bold.font = .body.bold()
    bold.foregroundColor = .blue
    str += bold
    return str
}

Text(styled).textSelection(.enabled)
```

## WebKit JS 桥接（双向通信）
```swift
import WebKit

struct WebBridgeView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.userContentController.add(context.coordinator, name: "nativeHandler")
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.load(URLRequest(url: URL(string: "https://example.com")!))
        return webView
    }
    func updateUIView(_ webView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator() }

    class Coordinator: NSObject, WKScriptMessageHandler {
        // JS 调用 Swift：window.webkit.messageHandlers.nativeHandler.postMessage("hello")
        func userContentController(_ controller: WKUserContentController,
                                   didReceive message: WKScriptMessage) {
            print("From JS: \(message.body)")
        }
    }
}

// Swift 调用 JS
webView.evaluateJavaScript("document.title") { result, error in
    if let title = result as? String { print(title) }
}
```

## HealthKit 进阶查询

### HKStatisticsQuery（聚合统计）
```swift
let stepsType = HKQuantityType(.stepCount)
let today = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: .now), end: .now)

let query = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: today, options: .cumulativeSum) {
    _, stats, _ in
    let totalSteps = stats?.sumQuantity()?.doubleValue(for: .count()) ?? 0
    DispatchQueue.main.async { self.steps = Int(totalSteps) }
}
healthStore.execute(query)
```

### HKAnchoredObjectQuery（增量同步，iOS 17+ Descriptor）
```swift
let descriptor = HKAnchoredObjectQueryDescriptor(
    predicates: [.quantitySample(type: HKQuantityType(.heartRate))],
    anchor: savedAnchor
)
let results = try await descriptor.result(for: healthStore)
let newSamples = results.addedSamples      // 新增样本
let deletedObjects = results.deletedObjects // 已删除
let newAnchor = results.newAnchor           // 保存用于下次增量
```

### 临床记录（FHIR，需 Clinical Health Records 权限）
```swift
let allergyType = HKObjectType.clinicalType(forIdentifier: .allergyRecord)!
let query = HKSampleQuery(sampleType: allergyType, predicate: nil, limit: 100, sortDescriptors: nil) {
    _, samples, _ in
    let records = samples as? [HKClinicalRecord] ?? []
    for record in records {
        if let fhir = record.fhirResource {
            let json = try? JSONSerialization.jsonObject(with: fhir.data) as? [String: Any]
            // 解析 FHIR Condition / Medication / Procedure
        }
    }
}
healthStore.execute(query)
```

## CloudKit 订阅 + 批量操作

### CKSubscription（远程变更推送通知）
```swift
let subscription = CKQuerySubscription(
    recordType: "TodoItem",
    predicate: NSPredicate(value: true),
    subscriptionID: "all-todos",
    options: [.firesOnRecordCreation, .firesOnRecordUpdate]
)
let info = CKSubscription.NotificationInfo()
info.shouldSendContentAvailable = true   // 静默推送触发后台刷新
subscription.notificationInfo = info
try await database.save(subscription)
```

### CKQueryOperation（游标分页）
```swift
let query = CKQuery(recordType: "Item", predicate: NSPredicate(value: true))
let operation = CKQueryOperation(query: query)
operation.resultsLimit = 50

var allRecords: [CKRecord] = []
operation.recordMatchedBlock = { _, result in
    if case .success(let record) = result { allRecords.append(record) }
}
operation.queryResultBlock = { result in
    if case .success(let cursor) = result, let cursor {
        // 还有更多数据，用 cursor 继续查询
        let nextOp = CKQueryOperation(cursor: cursor)
        // ... 递归或循环
    }
}
database.add(operation)
```


## Modal 弹出（Sheet / FullScreenCover / Alert / Popover）
```swift
@State private var showSheet = false
@State private var showAlert = false

// Sheet（半屏）
Button("Show Sheet") { showSheet = true }
    .sheet(isPresented: $showSheet) {
        DetailView()
            .presentationDetents([.medium, .large])   // 可拖拽高度
            .presentationDragIndicator(.visible)
    }

// FullScreenCover（全屏）
.fullScreenCover(isPresented: $showFull) { FullView() }

// Alert
Button("Delete") { showAlert = true }
    .alert("Are you sure?", isPresented: $showAlert) {
        Button("Delete", role: .destructive) { delete() }
        Button("Cancel", role: .cancel) { }
    } message: {
        Text("This action cannot be undone.")
    }

// Confirmation Dialog（操作表）
.confirmationDialog("Options", isPresented: $showOptions) {
    Button("Share") { }
    Button("Delete", role: .destructive) { }
}

// Popover（iPad / Mac 弹出气泡）
.popover(isPresented: $showPopover, arrowEdge: .top) {
    Text("Popover content").padding()
}
```

## NavigationSplitView（iPad / Mac 分栏导航）
```swift
@State private var selectedCategory: Category?
@State private var selectedItem: Item?

NavigationSplitView {
    List(categories, selection: $selectedCategory) { category in
        Label(category.name, systemImage: category.icon)
    }
    .navigationTitle("Categories")
} content: {
    if let category = selectedCategory {
        List(category.items, selection: $selectedItem) { item in
            Text(item.title)
        }
    }
} detail: {
    if let item = selectedItem {
        DetailView(item: item)
    } else {
        ContentUnavailableView("Select an Item", systemImage: "tray")
    }
}
.navigationSplitViewStyle(.balanced)
```

## ContentUnavailableView（空状态）
```swift
// 系统预设搜索空状态
ContentUnavailableView.search(text: searchText)

// 自定义空状态
ContentUnavailableView {
    Label("No Items", systemImage: "tray")
} description: {
    Text("Add items to get started.")
} actions: {
    Button("Add Item") { addItem() }
}
```

## Swift Charts（数据可视化）
```swift
import Charts

struct SalesData: Identifiable {
    let id = UUID()
    let month: String
    let revenue: Double
}

struct SalesChart: View {
    let data: [SalesData]
    var body: some View {
        Chart(data) { item in
            BarMark(
                x: .value("Month", item.month),
                y: .value("Revenue", item.revenue)
            )
            .foregroundStyle(.blue.gradient)
        }
        .chartYAxis { AxisMarks(preset: .aligned) }
        .frame(height: 200)
    }
}

// 折线图
Chart(data) { item in
    LineMark(x: .value("Month", item.month), y: .value("Revenue", item.revenue))
        .interpolationMethod(.catmullRom)
    AreaMark(x: .value("Month", item.month), y: .value("Revenue", item.revenue))
        .foregroundStyle(.blue.opacity(0.1))
}
```

## PhotosPicker（照片选择器）
```swift
import PhotosUI

@State private var selectedPhoto: PhotosPickerItem?
@State private var image: Image?

PhotosPicker("Select Photo", selection: $selectedPhoto, matching: .images)
    .onChange(of: selectedPhoto) { _, newItem in
        Task {
            if let data = try? await newItem?.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                image = Image(uiImage: uiImage)
            }
        }
    }

// 多选
@State private var selectedPhotos: [PhotosPickerItem] = []
PhotosPicker("Select Photos", selection: $selectedPhotos, maxSelectionCount: 5, matching: .images)
```

## ShareLink（系统分享）
```swift
ShareLink(item: URL(string: "https://example.com")!) {
    Label("Share", systemImage: "square.and.arrow.up")
}

// 自定义 Transferable
ShareLink(item: myDocument, preview: SharePreview(myDocument.title, image: myDocument.thumbnail))
```

## TipKit（上下文提示）
```swift
import TipKit

struct FavoriteTip: Tip {
    var title: Text { Text("Save as Favorite") }
    var message: Text? { Text("Tap the heart to save this item.") }
    var image: Image? { Image(systemName: "heart") }
}

struct ItemView: View {
    let tip = FavoriteTip()
    var body: some View {
        Button { } label: { Image(systemName: "heart") }
            .popoverTip(tip)          // 气泡提示
        // 或 TipView(tip)            // 内联提示
    }
}

// App 入口配置
@main
struct MyApp: App {
    init() { try? Tips.configure() }
}
```

## LazyVGrid / LazyHGrid（网格布局）
```swift
let columns = [
    GridItem(.adaptive(minimum: 100)),  // 自适应列数
]

LazyVGrid(columns: columns, spacing: 16) {
    ForEach(items) { item in
        ItemCard(item: item)
    }
}

// 固定列
let fixedColumns = [
    GridItem(.fixed(120)),
    GridItem(.fixed(120)),
    GridItem(.flexible()),
]
```

## Shape / Path / Gradient（自定义绘图）
```swift
// 自定义形状
struct Star: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            let center = CGPoint(x: rect.midX, y: rect.midY)
            // 绘制五角星路径...
            path.move(to: CGPoint(x: center.x, y: rect.minY))
            // ...
        }
    }
}

Star().fill(.yellow).frame(width: 100, height: 100)

// 渐变
LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
RadialGradient(colors: [.white, .black], center: .center, startRadius: 0, endRadius: 100)
AngularGradient(colors: [.red, .yellow, .green, .blue, .red], center: .center)
```

## EnvironmentKey 自定义环境值
```swift
// 定义
struct ThemeKey: EnvironmentKey {
    static var defaultValue: Theme = .light
}
extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

// Swift 6 简写（@Entry 宏）
extension EnvironmentValues {
    @Entry var appAccentColor: Color = .blue
}

// 注入
ContentView().environment(\.theme, .dark)

// 读取
@Environment(\.theme) private var theme
```

## OSLog / Logger（结构化日志）
```swift
import os

let logger = Logger(subsystem: "com.app.myapp", category: "networking")

logger.info("Request started: \(url.absoluteString)")
logger.debug("Response: \(data.count) bytes")
logger.error("Failed: \(error.localizedDescription, privacy: .public)")
logger.fault("Critical failure")   // 最高级别

// 在 Instruments 中用 os_signpost 追踪性能区间
let signposter = OSSignposter(logger: logger)
let state = signposter.beginInterval("loadData")
// ... 执行操作
signposter.endInterval("loadData", state)
```

## Live Activities（ActivityKit 实时活动）
```swift
import ActivityKit

// 定义 Attributes
struct DeliveryAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var status: String
        var estimatedArrival: Date
    }
    var orderNumber: String
}

// 启动 Live Activity
let attributes = DeliveryAttributes(orderNumber: "12345")
let state = DeliveryAttributes.ContentState(status: "On the way", estimatedArrival: .now.addingTimeInterval(1800))
let activity = try Activity.request(attributes: attributes, content: .init(state: state, staleDate: nil))

// 更新
let newState = DeliveryAttributes.ContentState(status: "Delivered", estimatedArrival: .now)
await activity.update(.init(state: newState, staleDate: nil))

// 结束
await activity.end(.init(state: newState, staleDate: nil), dismissalPolicy: .after(.now + 3600))
```

## TimelineView（定时刷新 View）
```swift
// 每秒刷新（时钟等场景）
TimelineView(.periodic(from: .now, by: 1.0)) { timeline in
    Text(timeline.date.formatted(.dateTime.hour().minute().second()))
        .font(.largeTitle.monospacedDigit())
}
```


## Deep Link / Universal Links
```swift
// URL Scheme（自定义协议）
// Info.plist: CFBundleURLSchemes = ["myapp"]
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in   // myapp://item/123
                    if let id = parseItemID(from: url) { navigate(to: id) }
                }
        }
    }
}

// Universal Links（HTTPS 域名关联）
// apple-app-site-association 文件放在域名 /.well-known/ 下
// {"applinks":{"apps":[],"details":[{"appIDs":["TEAMID.com.app.id"],"paths":["/item/*"]}]}}

// 打开外部 URL
@Environment(\.openURL) private var openURL
Button("Open Website") { openURL(URL(string: "https://example.com")!) }
```

## App 发布必备

### Privacy Manifest（PrivacyInfo.xcprivacy，App Store 强制）
```xml
<!-- 声明使用的隐私 API 和数据类型 -->
<dict>
    <key>NSPrivacyAccessedAPITypes</key>
    <array>
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array><string>CA92.1</string></array>
        </dict>
    </array>
    <key>NSPrivacyCollectedDataTypes</key>
    <array><!-- 声明收集的数据类型 --></array>
</dict>
```

### App Tracking Transparency（IDFA 追踪授权）
```swift
import AppTrackingTransparency

func requestTrackingPermission() {
    ATTrackingManager.requestTrackingAuthorization { status in
        switch status {
        case .authorized: print("Tracking allowed")
        case .denied, .restricted: print("Tracking denied")
        case .notDetermined: break
        @unknown default: break
        }
    }
}
// Info.plist 必须添加 NSUserTrackingUsageDescription
```

### In-App Review（请求评分）
```swift
import StoreKit
@Environment(\.requestReview) private var requestReview

// 在合适时机触发（用户完成关键操作后）
requestReview()
// 系统自动限制弹出频率，无需手动节流
```

### Info.plist 常用配置
```xml
NSCameraUsageDescription        <!-- 相机权限说明 -->
NSMicrophoneUsageDescription    <!-- 麦克风 -->
NSLocationWhenInUseUsageDescription  <!-- 位置 -->
NSPhotoLibraryUsageDescription  <!-- 相册 -->
NSHealthShareUsageDescription   <!-- HealthKit 读取 -->
NSFaceIDUsageDescription        <!-- Face ID -->
NSUserTrackingUsageDescription  <!-- 追踪 -->
UIBackgroundModes               <!-- 后台模式 -->
```

## App Groups + iCloud KV Store
```swift
// App Groups（App / Widget / Extension 共享数据）
let sharedDefaults = UserDefaults(suiteName: "group.com.app.shared")
sharedDefaults?.set("value", forKey: "key")

// 共享文件目录
let groupURL = FileManager.default.containerURL(
    forSecurityApplicationGroupIdentifier: "group.com.app.shared"
)!

// iCloud Key-Value Store（跨设备小数据同步，限 1MB）
let kvStore = NSUbiquitousKeyValueStore.default
kvStore.set("value", forKey: "key")
kvStore.synchronize()
// 监听远程变更
NotificationCenter.default.addObserver(forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
    object: kvStore, queue: .main) { _ in /* 刷新 UI */ }
```

## Spotlight 索引（CoreSpotlight）
```swift
import CoreSpotlight
import MobileCoreServices

// 索引内容
let item = CSSearchableItem(
    uniqueIdentifier: "item-\(id)",
    domainIdentifier: "com.app.items",
    attributeSet: {
        let attrs = CSSearchableItemAttributeSet(contentType: .text)
        attrs.title = "My Item"
        attrs.contentDescription = "Description"
        attrs.thumbnailData = thumbnailData
        return attrs
    }()
)
CSSearchableIndex.default().indexSearchableItems([item])

// 处理点击搜索结果
.onContinueUserActivity(CSSearchableItemActionType) { activity in
    if let id = activity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
        navigate(to: id)
    }
}
```

## Home Screen Quick Actions
```swift
// Info.plist 静态快捷方式
// UIApplicationShortcutItems: [{UIApplicationShortcutItemType: "newItem", UIApplicationShortcutItemTitle: "New Item", UIApplicationShortcutItemIconType: "UIApplicationShortcutIconTypeAdd"}]

// 动态快捷方式
UIApplication.shared.shortcutItems = [
    UIApplicationShortcutItem(type: "search", localizedTitle: "Search", localizedSubtitle: nil,
        icon: UIApplicationShortcutIcon(systemImageName: "magnifyingglass"))
]

// 处理
.onContinueUserActivity("newItem") { _ in showNewItem = true }
```

## Widget 进阶（WidgetFamily / Dynamic Island / Lock Screen）
```swift
import WidgetKit

struct MyWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "myWidget", provider: MyProvider()) { entry in
            MyWidgetView(entry: entry)
        }
        .supportedFamilies([
            .systemSmall, .systemMedium, .systemLarge,    // 主屏幕
            .accessoryCircular, .accessoryRectangular,    // Lock Screen
            .accessoryInline                               // Lock Screen 单行
        ])
    }
}

// 根据 family 适配布局
@Environment(\.widgetFamily) var family
switch family {
case .systemSmall: CompactView()
case .accessoryCircular: Gauge(value: progress) { Image(systemName: "bolt") }
default: FullView()
}
```

## Extensions（扩展类型）
```swift
// Share Extension：接收系统分享内容
// 新建 Target → Share Extension，在 SLComposeServiceViewController 中处理

// Notification Service Extension：修改推送内容（加密解密、附件下载）
class NotificationService: UNNotificationServiceExtension {
    override func didReceive(_ request: UNNotificationRequest,
        withContentHandler handler: @escaping (UNNotificationContent) -> Void) {
        let content = request.content.mutableCopy() as! UNMutableNotificationContent
        content.title = "Modified: \(content.title)"
        // 下载附件、解密内容等
        handler(content)
    }
}
```

## 常用修饰符速查
```swift
// List 样式
.listStyle(.plain)              // 或 .insetGrouped, .sidebar, .grouped
.listRowBackground(Color.clear) // 自定义行背景
.listRowSeparator(.hidden)      // 隐藏分隔线

// 外观
.preferredColorScheme(.dark)    // 强制深色
.tint(.orange)                  // 控件着色
.foregroundStyle(.secondary)    // 文字层级
.labelStyle(.titleAndIcon)      // Label 样式
.toggleStyle(.switch)           // Toggle 样式
.buttonStyle(.borderedProminent)

// 布局
.fixedSize()                    // 不压缩内容
.fixedSize(horizontal: false, vertical: true)  // 仅垂直不压缩
.layoutPriority(1)              // 布局优先级

// 视觉
.blur(radius: 10)               // 模糊
.shadow(color: .black.opacity(0.2), radius: 8, y: 4)
.rotation3DEffect(.degrees(15), axis: (x: 1, y: 0, z: 0))
.mask { LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom) }
.compositingGroup()             // 合并子视图后再应用效果
.drawingGroup()                 // Metal 加速渲染（大量图层时）

// 交互
.disabled(isLoading)
.allowsHitTesting(false)        // 穿透点击
.opacity(isVisible ? 1 : 0)
.hidden()                       // 隐藏但保留空间

// 编辑
@Environment(\.editMode) private var editMode
EditButton()                    // 切换编辑模式
@Environment(\.undoManager) private var undoManager
undoManager?.registerUndo(withTarget: self) { $0.undo() }

// 搜索增强
.searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
.searchSuggestions {
    ForEach(suggestions) { s in Text(s.title).searchCompletion(s.query) }
}
.searchScopes($scope) {
    Text("All").tag(SearchScope.all)
    Text("Recent").tag(SearchScope.recent)
}

// 多平台条件编译
#if os(iOS)
// iPhone / iPad
#elseif os(macOS)
// Mac
#elseif os(watchOS)
// Apple Watch
#elseif os(tvOS)
// Apple TV
#elseif os(visionOS)
// Vision Pro
#endif
```


## 常用控件速查

### 表单控件
```swift
Form {
    Section("Account") {
        TextField("Username", text: $username)
            .textContentType(.username)
            .onSubmit { login() }              // 键盘回车触发
            .submitLabel(.done)                 // 回车键文字

        SecureField("Password", text: $password)
            .textContentType(.password)

        DatePicker("Birthday", selection: $date, displayedComponents: .date)
        MultiDatePicker("Dates", selection: $dates)

        ColorPicker("Theme", selection: $color, supportsOpacity: false)

        Stepper("Quantity: \(qty)", value: $qty, in: 1...99)

        Picker("Language", selection: $lang) {
            Text("English").tag("en")
            Text("中文").tag("zh")
        }
        .pickerStyle(.menu)   // 或 .segmented, .wheel, .navigationLink

        Toggle("Notifications", isOn: $notifyOn)
        Slider(value: $volume, in: 0...1) { Text("Volume") }

        LabeledContent("Version", value: "2.1.0")
    }

    Section("Status") {
        Gauge(value: progress) { Text("Progress") }
            .gaugeStyle(.accessoryCircular)
        ProgressView(value: 0.7)
    }
}
```

### ZStack / overlay
```swift
ZStack(alignment: .bottomTrailing) {
    Image("photo").resizable().scaledToFill()
    Text("Badge").padding(6).background(.red).clipShape(Capsule())
}

// overlay 等效写法
Image("photo")
    .overlay(alignment: .bottomTrailing) {
        Text("Badge").padding(6).background(.red).clipShape(Capsule())
    }
```

### ToolbarItem
```swift
.toolbar {
    ToolbarItem(placement: .primaryAction) {
        Button("Save", action: save)
    }
    ToolbarItem(placement: .cancellationAction) {
        Button("Cancel", role: .cancel) { dismiss() }
    }
    ToolbarItemGroup(placement: .bottomBar) {
        Spacer()
        Text("\(items.count) items")
        Spacer()
    }
    ToolbarItem(placement: .keyboard) {
        Button("Done") { focusedField = nil }  // 键盘上方按钮
    }
}
```

### ContextMenu + swipeActions
```swift
// 长按菜单
Text(item.title)
    .contextMenu {
        Button("Copy", systemImage: "doc.on.doc") { copy(item) }
        Button("Delete", systemImage: "trash", role: .destructive) { delete(item) }
    } preview: {
        ItemPreview(item: item)   // 自定义预览
    }

// 列表滑动操作
List {
    ForEach(items) { item in
        Text(item.title)
            .swipeActions(edge: .trailing) {
                Button("Delete", role: .destructive) { delete(item) }
                Button("Archive") { archive(item) }.tint(.orange)
            }
            .swipeActions(edge: .leading) {
                Button("Pin") { pin(item) }.tint(.yellow)
            }
    }
}
```

### ScrollViewReader + scrollTo
```swift
ScrollViewReader { proxy in
    ScrollView {
        LazyVStack {
            ForEach(messages) { msg in
                MessageRow(msg).id(msg.id)
            }
        }
    }
    .onChange(of: messages.count) { _, _ in
        withAnimation {
            proxy.scrollTo(messages.last?.id, anchor: .bottom)
        }
    }
}

// iOS 17+ scrollPosition
@State private var scrollPosition: Int?
ScrollView {
    LazyVStack { ForEach(0..<100) { i in Text("Item \(i)").id(i) } }
}
.scrollPosition(id: $scrollPosition)
.scrollTargetBehavior(.viewAligned)   // 吸附对齐
.scrollTargetLayout()                  // 配合使用
```

### GeometryReader
```swift
GeometryReader { proxy in    // proxy: GeometryProxy
    let width = proxy.size.width
    let height = proxy.size.height
    let safeTop = proxy.safeAreaInsets.top

    HStack(spacing: 0) {
        Color.red.frame(width: width * 0.3)
        Color.blue.frame(width: width * 0.7)
    }
}
```

### DisclosureGroup / OutlineGroup / GroupBox
```swift
// 折叠展开
DisclosureGroup("Advanced Settings") {
    Toggle("Debug Mode", isOn: $debug)
}

// 多级树形结构
OutlineGroup(data, children: \.children) { item in
    Text(item.name)
}

// 带标题的分组框
GroupBox("Statistics") {
    LabeledContent("Total", value: "\(total)")
    LabeledContent("Average", value: "\(average)")
}
```

## @FocusState + 文件导入导出
```swift
// 焦点管理
enum Field: Hashable { case email, password }
@FocusState private var focusedField: Field?

TextField("Email", text: $email)
    .focused($focusedField, equals: .email)
SecureField("Password", text: $password)
    .focused($focusedField, equals: .password)
Button("Login") { focusedField = nil }  // 收起键盘

// 文件导入
.fileImporter(isPresented: $showImporter, allowedContentTypes: [.json, .plainText]) { result in
    switch result {
    case .success(let url):
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        let data = try Data(contentsOf: url)
    case .failure(let error): print(error)
    }
}

// 文件导出
.fileExporter(isPresented: $showExporter, document: myDoc, contentType: .json) { result in
    // handle result
}
```

## SF Symbols 效果 + 触觉反馈
```swift
// symbolEffect 动画
Image(systemName: "wifi")
    .symbolEffect(.variableColor.iterative)      // 循环变色
Image(systemName: "arrow.down.circle")
    .symbolEffect(.bounce, value: downloadCount)  // 值变化时弹跳
Image(systemName: "heart.fill")
    .symbolRenderingMode(.multicolor)              // 多色渲染
    .contentTransition(.symbolEffect(.replace))    // 符号切换动画

// 触觉反馈（iOS 17+）
Button("Tap") { action() }
    .sensoryFeedback(.impact(weight: .medium), trigger: tapCount)
// 可选：.success, .warning, .error, .selection, .impact, .increase, .decrease
```

## 隐私 + Sheet 控制 + 安全区域
```swift
// 敏感内容遮盖
Text(bankBalance)
    .privacySensitive()        // 锁屏 Widget 自动遮盖
    .redacted(reason: .placeholder)  // 占位效果（加载中）

// 禁止下拉关闭 Sheet
.sheet(isPresented: $show) {
    EditView()
        .interactiveDismissDisabled(hasUnsavedChanges)
}

// 安全区域扩展
.safeAreaInset(edge: .bottom) {
    HStack { Button("Save") { } }.padding().background(.bar)
}
.safeAreaPadding(.horizontal, 20)

// 容器相对尺寸（iOS 17+）
Image("photo")
    .containerRelativeFrame(.horizontal) { length, _ in length * 0.8 }
```

## ImageRenderer（View 导出为图片）
```swift
let renderer = ImageRenderer(content: MyChartView())
renderer.scale = UIScreen.main.scale   // Retina 适配
if let uiImage = renderer.uiImage {
    UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
}
// 也支持导出 PDF
if let data = renderer.render { _, renderer in renderer.addPages() } { }
```

## MapKit 标注
```swift
import MapKit

Map {
    Marker("Apple Park", coordinate: CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090))
        .tint(.red)
    Annotation("Custom", coordinate: coord) {
        Image(systemName: "star.fill").foregroundStyle(.yellow)
            .padding(6).background(.blue).clipShape(Circle())
    }
    MapPolyline(coordinates: routeCoords).stroke(.blue, lineWidth: 3)
}
.mapStyle(.standard(elevation: .realistic))
```

## Swift 并发进阶
```swift
// async let 并行
async let profile = fetchProfile()
async let posts = fetchPosts()
async let friends = fetchFriends()
let (p, ps, f) = try await (profile, posts, friends)  // 并行等待

// TaskGroup
let results = try await withThrowingTaskGroup(of: Data.self) { group in
    for url in urls {
        group.addTask { try await URLSession.shared.data(from: url).0 }
    }
    var allData: [Data] = []
    for try await data in group { allData.append(data) }
    return allData
}

// Continuation 桥接回调
func fetchLegacy() async throws -> String {
    try await withCheckedThrowingContinuation { continuation in
        legacyAPI { result, error in
            if let error { continuation.resume(throwing: error) }
            else { continuation.resume(returning: result!) }
        }
    }
}

// Sendable + nonisolated
struct UserData: Sendable { let name: String }   // 值类型自动 Sendable

actor DataStore {
    var items: [Item] = []
    nonisolated var description: String { "DataStore" }  // 无需 await
}

// 自定义 GlobalActor
@globalActor actor DatabaseActor: GlobalActor {
    static let shared = DatabaseActor()
}
@DatabaseActor func saveToDatabase() { }
```


## SwiftData 进阶（iOS 26 扩展文档）

### Model 继承（iOS 26+）
```swift
@Model class Trip {
    @Attribute(.preserveValueOnDeletion)   // 删除时保留审计记录
    var name: String
    var destination: String
    @Relationship(deleteRule: .cascade, inverse: \BucketListItem.trip)
    var bucketList: [BucketListItem] = []
}

@available(iOS 26, *)
@Model class BusinessTrip: Trip {
    var expenseCode: String
    var perDiemRate: Double
    @Relationship(deleteRule: .cascade, inverse: \DailyMileageRecord.trip)
    var milesDriven: [DailyMileageRecord] = []
}

@available(iOS 26, *)
@Model class PersonalTrip: Trip {
    enum Reason: String, Codable { case family, wellness, reunion }
    var reason: Reason
}

// 基类查询返回所有子类；类型过滤用 #Predicate
@Query var allTrips: [Trip]                     // 包含 Business + Personal
let bizOnly = allTrips.filter { $0 is BusinessTrip }
```

### Undo/Redo 支持
```swift
// App 入口一行启用
.modelContainer(for: Item.self, isUndoEnabled: true)
// 三指滑动自动支持撤销/重做，无需额外代码
```

### CloudKit iCloud 同步
```swift
let config = ModelConfiguration(
    cloudKitDatabase: .private("iCloud.com.example.MyApp")
)
let container = try ModelContainer(for: Trip.self, configurations: config)
// 自动双向同步到 iCloud，无需手动管理 CKRecord
```

## Control Widget（控制中心 / 锁屏 / Action 按钮）
```swift
import WidgetKit
import AppIntents

struct TimerToggle: ControlWidget {
    static let kind = "com.app.timerToggle"

    var body: some ControlWidgetConfiguration {
        AppIntentControlConfiguration(kind: Self.kind, provider: TimerProvider()) { state in
            ControlWidgetToggle(state.name, isOn: state.isRunning, action: ToggleTimerIntent(timer: state.timer))
        }
        .displayName("Timer")
        .description("Start and stop a timer.")
    }
}

struct ToggleTimerIntent: SetValueIntent {
    static var title: LocalizedStringResource = "Toggle Timer"
    @Parameter(title: "Timer") var timer: TimerEntity
    @Parameter(title: "Running") var value: Bool
    func perform() async throws -> some IntentResult { .result() }
}
```

## App Intents 进阶（扩展文档）

### Entity 属性查询 + Spotlight 索引
```swift
struct LandmarkEntity: AppEntity, IndexedEntity {
    static var defaultQuery = LandmarkEntityQuery()

    @Property(title: "Name")
    var name: String

    // Spotlight 自动索引
    static func updateSpotlightIndex() {
        let entities = LandmarkDataManager.shared.landmarks.map { LandmarkEntity(landmark: $0) }
        CSSearchableIndex.default().indexAppEntities(entities)
    }
}

// 属性查询（Shortcuts 可用 "Find landmarks where name contains ..."）
struct LandmarkEntityQuery: EntityPropertyQuery {
    func entities(matching predicates: [NSPredicate]) async throws -> [LandmarkEntity] {
        // 根据谓词过滤
    }
}
```

### 参数消歧（多个匹配时让用户选择）
```swift
func perform() async throws -> some IntentResult {
    let matches = findMatches(for: location)
    if matches.count > 1 {
        throw $location.needsDisambiguationError(
            among: matches,
            dialog: "Which location did you mean?"
        )
    }
    return .result()
}
```

## UIKit Trait 注册（iOS 17+，替代 traitCollectionDidChange）
```swift
override func viewDidLoad() {
    super.viewDidLoad()
    registerForTraitChanges([
        UITraitHorizontalSizeClass.self,
        UITraitVerticalSizeClass.self
    ]) { (self: Self, previous: UITraitCollection) in
        self.updateLayoutForCurrentTraitCollection()
    }
}
// 类型安全 + 无需手动比较 previousTraitCollection
```

## Vision 进阶（人脸质量评分 + 姿态角）
```swift
import Vision

// 人脸拍摄质量评分（0.0-1.0，综合光照/模糊/遮挡/角度）
let qualityRequest = VNDetectFaceCaptureQualityRequest()
let handler = VNImageRequestHandler(cgImage: cgImage)
try handler.perform([qualityRequest])
let quality = qualityRequest.results?.first?.faceCaptureQuality ?? 0  // 0.0-1.0

// 人脸姿态角（roll/pitch/yaw）
let poseRequest = VNDetectFaceRectanglesRequest()
try handler.perform([poseRequest])
if let face = poseRequest.results?.first {
    let roll = face.roll?.doubleValue ?? 0    // 头部倾斜
    let pitch = face.pitch?.doubleValue ?? 0  // 上下点头
    let yaw = face.yaw?.doubleValue ?? 0      // 左右转头
}
```

## ARKit 4K/HDR 视频捕获
```swift
// 4K 高清 AR 捕获
guard let hiResFormat = ARWorldTrackingConfiguration.recommendedVideoFormatFor4KResolution else { return }
var config = ARWorldTrackingConfiguration()
config.videoFormat = hiResFormat
config.videoHDRAllowed = true
arView.session.run(config)

// 随时捕获高分辨率帧
arView.session.captureHighResolutionFrame { frame, error in
    if let frame { saveHighResFrame(frame) }
}
```


## AVAudioEngine + AVAudioSession（音频处理）
```swift
import AVFoundation

// 配置音频会话
let audioSession = AVAudioSession.sharedInstance()
try audioSession.setCategory(.playback, mode: .default, policy: .longFormAudio)
try audioSession.setActive(true)

// AVAudioEngine（低延迟音频处理/播放）
let engine = AVAudioEngine()
let playerNode = AVAudioPlayerNode()
engine.attach(playerNode)
engine.connect(playerNode, to: engine.mainMixerNode, format: nil)
try engine.start()

let audioFile = try AVAudioFile(forReading: fileURL)
playerNode.scheduleFile(audioFile, at: nil)
playerNode.play()

// 空间音频（visionOS / AirPods）
try audioSession.setCategory(.playback, mode: .moviePlayback,
    options: [.allowAirPlay, .allowBluetooth])
// visionOS 自动支持空间音频，头部追踪通过 AVAudioSession 配置
```

## 视频编辑（AVMutableComposition + AVAssetWriter）
```swift
import AVFoundation

// 合并多段视频
let composition = AVMutableComposition()
let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!

let asset = AVAsset(url: videoURL)
let assetVideoTrack = try await asset.loadTracks(withMediaType: .video).first!
let duration = try await asset.load(.duration)
try videoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: duration), of: assetVideoTrack, at: .zero)

// AVAssetWriter 自定义输出
let writer = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)
let videoSettings: [String: Any] = [
    AVVideoCodecKey: AVVideoCodecType.hevc,
    AVVideoWidthKey: 1920,
    AVVideoHeightKey: 1080
]
let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
writer.add(writerInput)
writer.startWriting()
writer.startSession(atSourceTime: .zero)
```

## Metal / ShaderLibrary（GPU 加速渲染）
```swift
// SwiftUI visualEffect 修饰符（iOS 17+）
Text("Hello")
    .visualEffect { content, proxy in
        content.colorEffect(ShaderLibrary.rainbow(.float(proxy.size.width)))
    }

// SwiftUI + Metal Shader
let shader = ShaderLibrary.myShader(.float(time), .float2(size))
Rectangle()
    .colorEffect(shader)       // 颜色变换
    .distortionEffect(shader)  // 形变效果
    .layerEffect(shader)       // 图层效果

// drawingGroup（Metal 加速复杂视图合成）
VStack { /* 大量图层 */ }
    .drawingGroup()   // 离屏渲染后合成，提升性能
```

## visionOS 手部/平面/场景追踪
```swift
import ARKit

// 手部追踪（visionOS）
let handTracking = HandTrackingProvider()
let session = ARKitSession()
try await session.run([handTracking])
for await update in handTracking.anchorUpdates {
    let hand = update.anchor
    if let indexTip = hand.skeleton.joint(.indexFingerTip) {
        let position = indexTip.anchorFromJointTransform
    }
}

// 平面检测
let planeDetection = PlaneDetectionProvider(alignments: [.horizontal, .vertical])
try await session.run([planeDetection])
for await update in planeDetection.anchorUpdates {
    let plane = update.anchor
    let extent = plane.geometry.extent  // 平面大小
}

// 场景重建（网格）
let sceneReconstruction = SceneReconstructionProvider()
try await session.run([sceneReconstruction])

// 世界追踪
let worldTracking = WorldTrackingProvider()
try await session.run([worldTracking])
```

## RealityKit 物理 + 碰撞
```swift
import RealityKit

// 添加物理体
let entity = ModelEntity(mesh: .generateSphere(radius: 0.1))
entity.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(
    massProperties: .default,
    material: .generate(friction: 0.5, restitution: 0.8),
    mode: .dynamic
)
entity.components[CollisionComponent.self] = CollisionComponent(
    shapes: [.generateSphere(radius: 0.1)]
)

// 施加力/速度
entity.components[PhysicsMotionComponent.self] = PhysicsMotionComponent(
    linearVelocity: [0, 2, 0]   // 向上发射
)

// AnchorEntity（空间锚定）
let anchor = AnchorEntity(.plane(.horizontal, classification: .floor, minimumBounds: [0.5, 0.5]))
anchor.addChild(entity)
arView.scene.addAnchor(anchor)
```

## HKWorkout（运动追踪）
```swift
import HealthKit

// 开始运动会话（watchOS）
let config = HKWorkoutConfiguration()
config.activityType = .running
config.locationType = .outdoor

let session = try HKWorkoutSession(healthStore: healthStore, configuration: config)
let builder = session.associatedWorkoutBuilder()
builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: config)

session.startActivity(with: .now)
try await builder.beginCollection(at: .now)

// 结束运动
session.end()
try await builder.endCollection(at: .now)
let workout = try await builder.finishWorkout()

// 添加运动样本
let energySample = HKQuantitySample(type: .quantityType(forIdentifier: .activeEnergyBurned)!,
    quantity: HKQuantity(unit: .kilocalorie(), doubleValue: 300),
    start: startDate, end: endDate)
try await builder.add([energySample])
```

## Apple Pencil 交互
```swift
// 悬停检测（iPad Pro + Apple Pencil 2）
Rectangle()
    .onPencilHover { phase, location, altitude in
        // phase: .began, .changed, .ended
        // altitude: 笔尖倾斜角度
        hoverLocation = location
    }

// Pencil 双击手势（切换工具）
@Environment(\.pencilPreferredAction) private var preferredAction

// PencilKit 绘图
import PencilKit
struct DrawingView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 5)
        canvasView.drawingPolicy = .anyInput
        return canvasView
    }
    func updateUIView(_ view: PKCanvasView, context: Context) {}
}
```

## App Clip
```swift
// App Clip 入口（轻量版 App，<15MB）
@main
struct MyAppClip: App {
    var body: some Scene {
        WindowGroup {
            AppClipView()
                .appStoreOverlay(isPresented: $showOverlay) {
                    SKOverlay.AppClipConfiguration(position: .bottom)
                }
        }
    }
}

// 处理 App Clip URL
.onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
    guard let url = activity.webpageURL else { return }
    handleAppClipURL(url)
}

// 配置：Xcode → Target → App Clip → Associated Domains
// 需要在 apple-app-site-association 中配置 appclips 字段
```

## Xcode 开发者工具速查

### 崩溃报告分析
```
// Instruments 常用工具
Time Profiler     → CPU 热点定位
Allocations       → 内存增长分析
Leaks             → 内存泄漏检测
Network           → 网络请求分析
SwiftUI           → View Body Updates（Xcode 26 新增）

// 崩溃日志符号化
xcrun atos -o MyApp.dSYM/Contents/Resources/DWARF/MyApp -arch arm64 -l 0x100000000 0x1000012AB

// Xcode Cloud Webhook（CI/CD 集成外部服务）
// 最多 5 个 webhook / 产品，触发事件：build 创建/开始/完成
// POST payload 包含 build 状态、commit、artifact 信息
```

### 代码签名 + 配置文件
```
// 自动管理签名：Xcode → Signing & Capabilities → Automatically manage signing
// 手动管理：配置 provisioning profile + 证书
// Entitlements：HealthKit、App Groups、Push Notifications 等需在此添加

// TestFlight：Archive → Distribute → TestFlight → 上传 → App Store Connect 管理
```

### DocC 文档
```swift
/// 计算两个数的和。
///
/// 使用此方法执行基本加法运算。
///
/// ```swift
/// let result = add(2, 3) // returns 5
/// ```
///
/// - Parameters:
///   - a: 第一个数字。
///   - b: 第二个数字。
/// - Returns: 两个参数的和。
/// - Throws: 永不抛出。
func add(_ a: Int, _ b: Int) -> Int { a + b }

// 生成文档：Product → Build Documentation
// 支持 @Tutorial 编写交互式教程
```


## StoreKit 视图组件（iOS 17+）
```swift
import StoreKit

// 单个产品展示
ProductView(id: "com.app.premium") {
    Image(systemName: "crown")
}
.productViewStyle(.large)

// 订阅组展示（自动处理升级/降级）
SubscriptionStoreView(groupID: "premium_group")
    .subscriptionStoreControlStyle(.prominentPicker)
    .subscriptionStoreButtonLabel(.multiline)
    .containerBackground(for: .subscriptionStoreFullHeight) {
        LinearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom)
    }

// 实时监听交易更新
Task {
    for await result in Transaction.updates {
        if case .verified(let transaction) = result {
            await transaction.finish()
            unlockContent(for: transaction.productID)
        }
    }
}

// 恢复购买
try await AppStore.sync()
```

## Writing Tools 集成（iOS 26，自定义文本视图）
```swift
import UIKit

// 为自定义文本视图添加 Writing Tools 支持
let coordinator = UIWritingToolsCoordinator(delegate: self)
coordinator.preferredBehavior = .complete   // 或 .limited（仅校对）
coordinator.preferredResultOptions = [.richText, .list]
customTextView.addInteraction(coordinator)

// 实现委托：提供上下文
func writingToolsCoordinator(_ coordinator: UIWritingToolsCoordinator,
    requestsContextsFor scope: UIWritingToolsCoordinator.ContextScope,
    completion: @escaping ([UIWritingToolsCoordinator.Context]) -> Void) {
    switch scope {
    case .userSelection: completion([getSelectionContext()])
    case .fullDocument: completion([getFullDocumentContext()])
    default: completion([])
    }
}
```

## Widget containerBackground
```swift
// iOS 17+ Widget 背景（Smart Stack 自动移除背景）
struct MyWidgetView: View {
    var body: some View {
        VStack { content }
            .containerBackground(for: .widget) {
                LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom)
            }
    }
}
// Lock Screen widget 自动忽略背景
// accessoryWidgetBackground 用于小型锁屏 widget
```

## Vision 身体/手部姿态 + 人物分割 + 条码
```swift
import Vision

// 身体姿态检测
let bodyPoseRequest = VNDetectHumanBodyPoseRequest()
try VNImageRequestHandler(cgImage: image).perform([bodyPoseRequest])
if let observation = bodyPoseRequest.results?.first {
    let points = try observation.recognizedPoints(.torso)
    let neck = points[.neck]   // 各关节点位置 + 置信度
    let hip = points[.root]
}

// 手部姿态检测
let handPoseRequest = VNDetectHumanHandPoseRequest()
handPoseRequest.maximumHandCount = 2
try VNImageRequestHandler(cgImage: image).perform([handPoseRequest])
if let hand = handPoseRequest.results?.first {
    let thumbTip = try hand.recognizedPoint(.thumbTip)
    let indexTip = try hand.recognizedPoint(.indexTip)
    let distance = thumbTip.location.distance(to: indexTip.location)  // 捏合检测
}

// 人物分割（抠图）
let segRequest = VNGeneratePersonSegmentationRequest()
segRequest.qualityLevel = .balanced   // .fast / .balanced / .accurate
try VNImageRequestHandler(cgImage: image).perform([segRequest])
let mask = segRequest.results?.first?.pixelBuffer  // 遮罩 CVPixelBuffer

// 条码识别
let barcodeRequest = VNDetectBarcodesRequest()
barcodeRequest.symbologies = [.qr, .ean13, .code128]
try VNImageRequestHandler(cgImage: image).perform([barcodeRequest])
for barcode in barcodeRequest.results ?? [] {
    print(barcode.payloadStringValue ?? "")  // 条码内容
}
```

## ARKit 图像追踪 + 地理锚定
```swift
// 图像追踪（识别现实中的图片并叠加 AR 内容）
guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else { return }
let config = ARImageTrackingConfiguration()
config.trackingImages = referenceImages
config.maximumNumberOfTrackedImages = 4
arView.session.run(config)

func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
    for anchor in anchors.compactMap({ $0 as? ARImageAnchor }) {
        let imageName = anchor.referenceImage.name  // 识别到的图片名
        // 在图片位置放置 3D 内容
    }
}

// 地理锚定（特定 GPS 坐标放置 AR 内容）
ARGeoTrackingConfiguration.checkAvailability { available, _ in
    guard available else { return }
    let config = ARGeoTrackingConfiguration()
    arView.session.run(config)
}
let geoAnchor = ARGeoAnchor(coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194))
arView.session.add(anchor: geoAnchor)
```

## PhotogrammetrySession（3D 物体扫描）
```swift
import RealityKit

// 从照片重建 3D 模型
guard PhotogrammetrySession.isSupported else { return }
let session = try PhotogrammetrySession(input: photoFolderURL,
    configuration: PhotogrammetrySession.Configuration())
let request = PhotogrammetrySession.Request.modelFile(url: outputURL, detail: .full)
try session.process(requests: [request])

// 监听进度
for try await output in session.outputs {
    switch output {
    case .processingComplete: print("Done!")
    case .requestProgress(let request, let fraction): print("\(fraction * 100)%")
    case .requestError(_, let error): print("Error: \(error)")
    default: break
    }
}
```

## ReplayKit（屏幕录制）
```swift
import ReplayKit

// 应用内录屏
let recorder = RPScreenRecorder.shared()
recorder.startRecording { error in
    if let error { print("Recording failed: \(error)") }
}

// 停止并保存
recorder.stopRecording { previewController, error in
    if let preview = previewController {
        present(preview, animated: true)  // 预览/保存/分享
    }
}

// 实时采集（用于直播/AR 串流）
recorder.startCapture { sampleBuffer, bufferType, error in
    switch bufferType {
    case .video: processVideoFrame(sampleBuffer)
    case .audioApp: processAppAudio(sampleBuffer)
    case .audioMic: processMicAudio(sampleBuffer)
    @unknown default: break
    }
}
```

## UI 测试（XCUITest）
```swift
import XCTest

class MyAppUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        app.launch()
    }

    func testAddItem() {
        // 点击按钮
        app.buttons["Add Item"].tap()

        // 输入文字
        let textField = app.textFields["Item Name"]
        textField.tap()
        textField.typeText("New Item")

        // 验证元素存在
        XCTAssertTrue(app.staticTexts["New Item"].exists)

        // 滑动删除
        let cell = app.cells.containing(.staticText, identifier: "New Item").firstMatch
        cell.swipeLeft()
        app.buttons["Delete"].tap()
        XCTAssertFalse(app.staticTexts["New Item"].exists)
    }
}

// Swift Testing + XCTest 可共存于同一 test target，逐步迁移
```

## 常见坑点（2026 完整版）
1. **Liquid Glass**：多个 `.glassEffect()` 必须包在 `GlassEffectContainer` 中，否则性能严重下降
2. **Foundation Models**：必须 `prewarm()` + 用 `contextSize/tokenCount` 动态管理上下文
3. **SwiftData**：Schema 生产只能新增字段；`@Attribute(.unique)` 防重复；Preview 用 `inMemory: true`；CoreData 共存时开启 `NSPersistentHistoryTrackingKey`
4. **App Intents**：`AppShortcuts` 短语必须包含 `\(.applicationName)`；AssistantSchemas 需精确匹配 schema
5. **HealthKit**：每次启动重新检查权限；后台交付需配置 Background Modes；临床记录仅可读
6. **CloudKit**：加密字段不支持 CKAsset 和谓词查询；Schema 部署后不可删改字段
7. **CoreBluetooth**：RSSI >= -50 过滤弱信号；大数据分块传输并加 "EOM" 终止标记
8. **RealityKit**：SceneKit 已软废弃；ECS 管理复杂场景；visionOS 移动世界而非相机
9. **CoreMotion**：使用完毕立即 `stop*()`；visionOS 需在 immersive space 内才能获取数据
10. **AVFoundation**：`CaptureSession` 操作用 `actor` 隔离到后台线程；`CIContext` 全局复用
11. **Vision/CoreML**：Vision 坐标系原点在左下角，需用 `VNImageRectForNormalizedRect` 转换；模型编译后缓存到 Application Support
12. **ARKit**：协同会话前让用户设备靠拢扫描同一空间；`environmentTexturing` 消耗较多 GPU
13. **BackgroundTasks**：`BGContinuedProcessingTask` 需在 Xcode Capabilities 勾选；调试用 lldb `_simulateLaunch`
14. **StoreKit 2**：监听 `Transaction.updates` 处理服务端推送；`AppStore.sync()` 恢复购买
15. **EventKit**：iOS 17+ 优先用 `requestWriteOnlyAccessToEvents()` 降低权限打扰；监听 `EKEventStoreChanged`
16. **性能**：先用 Xcode 26 Performance Instrument profile，再优化；标准 Stack 优先，100+ 再用 LazyStack
17. **并发**：UI 更新必须在 `@MainActor`；共享可变状态用 `actor` 隔离；避免 `Task.detached` 逃逸主 actor
18. **Keychain**：`SecItemAdd` 前先 `SecItemDelete` 防重复；设置 `kSecAttrAccessibleWhenUnlocked` 保护数据
19. **Passkeys**：先检查 `authorizationStateForPlatformCredentials` 再发起请求；服务端需实现 WebAuthn 标准
20. **Accessibility**：用 `.accessibilityElement(children: .combine)` 合并卡片；避免图片缺少 `accessibilityLabel`
21. **Localization**：`^[count item](inflect: true)` 自动处理复数；日期/货币用 `.formatted()` 而非手动格式化
22. **DocumentGroup**：`FileDocument` 的 `readableContentTypes` 必须注册 UTType；`fileWrapper` 中用 `.atomic` 写入
23. **SpriteKit**：`SKScene.scaleMode = .resizeFill` 适配不同屏幕；物理引擎在后台会继续运行，切后台时 `isPaused = true`
24. **CIFilter**：`CIContext` 创建昂贵，全局仅创建一次；滤镜链自动合并优化
25. **Custom Layout**：`sizeThatFits` 和 `placeSubviews` 可能被多次调用，避免副作用；用 `makeCache` 缓存昂贵计算

## 持续更新资源
- SwiftUI：https://developer.apple.com/documentation/swiftui
- Foundation Models：https://developer.apple.com/documentation/foundationmodels
- HIG + Liquid Glass：https://developer.apple.com/design/human-interface-guidelines
- App Intents：https://developer.apple.com/documentation/appintents
- SwiftData：https://developer.apple.com/documentation/swiftdata
- WidgetKit：https://developer.apple.com/documentation/widgetkit
- RealityKit：https://developer.apple.com/documentation/realitykit
- ARKit：https://developer.apple.com/documentation/arkit
- Vision：https://developer.apple.com/documentation/vision
- CoreML：https://developer.apple.com/documentation/coreml
- CreateML：https://developer.apple.com/documentation/createml
- AVFoundation：https://developer.apple.com/documentation/avfoundation
- HealthKit：https://developer.apple.com/documentation/healthkit
- CloudKit：https://developer.apple.com/documentation/cloudkit
- StoreKit 2：https://developer.apple.com/documentation/storekit
- BackgroundTasks：https://developer.apple.com/documentation/backgroundtasks
- Swift Testing：https://developer.apple.com/documentation/testing
- Xcode Cloud：https://developer.apple.com/documentation/xcode/xcode-cloud
- SpriteKit：https://developer.apple.com/documentation/spritekit
- EventKit：https://developer.apple.com/documentation/eventkit
- Contacts：https://developer.apple.com/documentation/contacts
- CoreImage：https://developer.apple.com/documentation/coreimage
- CoreMotion：https://developer.apple.com/documentation/coremotion
- CoreBluetooth：https://developer.apple.com/documentation/corebluetooth
- NaturalLanguage：https://developer.apple.com/documentation/naturallanguage
- Network：https://developer.apple.com/documentation/network
- SafariServices：https://developer.apple.com/documentation/safariservices
- PassKit：https://developer.apple.com/documentation/passkit

**编辑规则**：仅修改此 SKILL.md → 运行 build 脚本生成各 AI 工具配置。
