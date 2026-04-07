---
name: swiftui-development
description: >
  SwiftUI + Swift 6.2 + Xcode 26 + Apple Intelligence 生产级开发知识包（iOS 26+ / iPadOS 26+ / macOS Tahoe 26+ / visionOS 26+）—— 声明式 UI、Liquid Glass、Foundation Models on-device AI、App Intents、SwiftData、WidgetKit、HealthKit、CloudKit、RealityKit、Apple Pay、CoreBluetooth、NaturalLanguage、CoreMotion 等完整框架覆盖。

  包含 350+ 代码示例、WWDC25/26 最佳实践、常见坑点。专为 Claude Code、Cursor、Xcode Coding Intelligence 等 AI 工具设计。

  Trigger keywords (EN): SwiftUI, Swift 6.2, Xcode 26, Apple Intelligence, Foundation Models, LanguageModelSession, @Generable, Guided Generation, Liquid Glass, glassEffect, GlassEffectContainer, glassEffectID, NavigationStack, zoom transition, @Observable, @Model, SwiftData, Observations AsyncSequence, WebView, Rich TextEditor, WidgetKit, Live Activities, App Intents, AppEntity, EntityQuery, AppShortcuts, HealthKit, CloudKit, RealityKit, RealityView, CoreBluetooth, NaturalLanguage, CoreMotion, Apple Pay, PassKit, Sign in with Apple, StoreKit 2, Xcode Cloud, DocC, Swift Testing, SF Symbols, visionOS, spatial layout

  触发关键词（中文）: SwiftUI, Swift 6.2, Xcode 26, 苹果智能, Foundation Models, Liquid Glass, SwiftData, WidgetKit, App Intents, HealthKit, CloudKit, RealityKit, 蓝牙, 自然语言, Apple Pay, 登录苹果账号, StoreKit, 内购, iOS 26 开发, 多平台适配
---

# SwiftUI Development - Production Knowledge Base（2026 年 4 月完整版）

专注 **iOS 26+ / Swift 6.2 / Xcode 26** 现代应用开发。覆盖 SwiftUI、Apple Intelligence、Liquid Glass、SwiftData、WidgetKit、App Intents、HealthKit、CloudKit、RealityKit、Apple Pay 等全套生产级框架。

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

## 导航（NavigationStack + Zoom 过渡）
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

## 常见坑点（2026 完整版）
1. **Liquid Glass**：多个 `.glassEffect()` 必须包在 `GlassEffectContainer` 中，否则性能严重下降
2. **Foundation Models**：必须 `prewarm()` + 用 `contextSize/tokenCount` 动态管理上下文
3. **SwiftData**：Schema 生产环境只能新增字段；`@Attribute(.unique)` 防重复；Preview 用 `inMemory: true`
4. **App Intents**：`AppShortcuts` 短语必须包含 `\(.applicationName)`；AssistantSchemas 需精确匹配 schema
5. **HealthKit**：每次启动重新检查权限状态；后台交付需同时配置 Background Modes
6. **CloudKit**：加密字段不支持 CKAsset 和查询；Schema 部署前在 Dashboard 确认
7. **CoreBluetooth**：RSSI >= -50 过滤无效连接；数据分块传输加 "EOM" 标记
8. **RealityKit**：SceneKit 已软废弃；使用 ECS 架构管理复杂场景；visionOS 移世界不移相机
9. **CoreMotion**：用完立即 `stop()`；visionOS 需在 immersive space 内才能获取数据
10. **StoreKit 2**：监听 `Transaction.updates` 处理服务端推送；`AppStore.sync()` 恢复购买
11. **性能**：先 profile 再优化；标准 Stack 优先，100+ 元素再用 LazyStack
12. **并发**：UI 更新必须在 `@MainActor`；共享状态用 `actor` 隔离

## 持续更新资源
- SwiftUI：https://developer.apple.com/documentation/swiftui
- Foundation Models：https://developer.apple.com/documentation/foundationmodels
- HIG + Liquid Glass：https://developer.apple.com/design/human-interface-guidelines
- App Intents：https://developer.apple.com/documentation/appintents
- SwiftData：https://developer.apple.com/documentation/swiftdata
- WidgetKit：https://developer.apple.com/documentation/widgetkit
- RealityKit：https://developer.apple.com/documentation/realitykit
- StoreKit 2：https://developer.apple.com/documentation/storekit
- Swift Testing：https://developer.apple.com/documentation/testing
- Xcode Cloud：https://developer.apple.com/documentation/xcode/xcode-cloud

**编辑规则**：仅修改此 SKILL.md → 运行 build 脚本生成各 AI 工具配置。
