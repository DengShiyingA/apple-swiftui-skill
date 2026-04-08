# Apple SwiftUI Development Skill

SwiftUI + Swift 6.2 + Xcode 26 + Apple Intelligence 生产级开发知识包。

专为 **Claude Code、Cursor、Windsurf、Xcode Coding Intelligence** 等 AI 编程工具设计的 Skill 文件，让 AI 助手具备完整的 Apple 生态开发能力。

## 特性

- **45+ 框架** 完整覆盖：SwiftUI、SwiftData、Foundation Models、Liquid Glass、ARKit、RealityKit、Vision、CoreML、AVFoundation、HealthKit、CloudKit、StoreKit 2 等
- **1000+ 代码示例**：每个 API 都有生产级 Swift 代码
- **90+ 常见坑点**：踩过的坑不用再踩
- **6 大平台**：iOS 26 / iPadOS 26 / macOS Tahoe 26 / visionOS 26 / watchOS 26 / tvOS 26
- **完整生产架构**：MVVM + Repository + UseCase、依赖注入、分页/无限滚动、图片缓存、深度链接路由、统一错误处理

## 覆盖内容

### 核心框架
| 框架 | 内容 |
|------|------|
| SwiftUI | 基础控件、导航、动画、手势、布局、修饰符、Charts、TipKit、PhotosPicker |
| Liquid Glass | 基础效果、GlassEffectContainer、背景延伸、UIKit UIGlassEffect、可访问性适配 |
| SwiftData | CRUD、关系、继承、History Tracking、Index/Unique、CloudKit 完整同步 |
| Foundation Models | Streaming、Guided Generation、Tool Calling、安全/Guardrails、Instruments 分析、Prompting 最佳实践、多语言 |
| App Intents | AppEntity、Shortcuts、Schemas、FocusFilter、交互式 Snippets |
| WidgetKit | Timeline、Interactive Widget、Lock Screen、Control Widget、Dynamic Island |

### 系统服务
| 框架 | 内容 |
|------|------|
| HealthKit | 查询、统计、锚点查询、运动路线、多运动 Workout、临床记录 |
| CloudKit | CRUD、加密、订阅、批量分页 |
| StoreKit 2 | 内购、订阅、退款处理、Win-Back Offers、促销 |
| CoreLocation | 异步位置、地理围栏(CLMonitor)、iBeacon、反向地理编码 |
| MapKit | 标注、叠加层、聚合、GeoJSON、本地搜索 |
| Network | NWPathMonitor、NWConnection TCP/UDP/TLS |
| UserNotifications | 可操作通知、通信通知、Critical Alerts、APNs HTTP/2 |
| EventKit / Contacts | 日历提醒、通讯录、ContactAccessButton |

### AI & 视觉
| 框架 | 内容 |
|------|------|
| CoreML + Vision | OCR、人脸检测、图像分类、轨迹检测、3D 姿态、实例分割、目标追踪、文档表格 |
| ARKit | 世界追踪、面部/手部追踪、LiDAR 深度、3D 对象扫描、场景重建、持久化世界地图、多用户 |
| RealityKit | RealityView、ECS、物理碰撞、粒子系统、自定义 Metal 着色器、IBL 光照 |
| CreateML | 图像分类、文本分类 |

### 音视频
| 框架 | 内容 |
|------|------|
| AVFoundation | 播放、相机拍摄(actor)、TTS、Audio Engine、视频编辑、色彩管理 |
| AVPlayer | Observation 框架(iOS 26)、进度监控 |
| HLS | 离线下载、缩略图生成 |
| SharePlay | 协调播放、自定义暂停 |

### 多平台
| 平台 | 内容 |
|------|------|
| watchOS | Extended Runtime Sessions、后台执行模式 |
| tvOS | Focus Engine、Game Controller |
| visionOS | Windows/Volumes/Immersive Spaces、Room Tracking、隐私 |
| macOS | Commands、多窗口、DocumentGroup |

### 安全 & 认证
Sign in with Apple、Passkeys、Face ID/Touch ID、CryptoKit、Security Key、Credential Provider Extension

### 开发工具
| 工具 | 内容 |
|------|------|
| Xcode 调试 | ASan/TSan/UBSan、断点、LLDB、内存图、View Debugger |
| Xcode 性能 | 启动时间、内存、响应性、磁盘写入、HTTP 分析、Smart Insights |
| Xcode 测试 | Swift Testing、XCUITest、代码覆盖率、性能测试、StoreKit 测试 |
| 发布分发 | Archive、TestFlight、App Store、Ad Hoc、Notarize、dSYM |
| App Store Connect API | JWT 生成、API Key、订阅组、TestFlight 自动化 |

### 生产架构模式
| 模式 | 内容 |
|------|------|
| MVVM + Repository + UseCase | 分层架构、@MainActor @Observable ViewModel、callAsFunction |
| 依赖注入 | 构造器注入、Environment Key、轻量 DI 容器、测试替换 |
| 分页/无限滚动 | PaginationState 状态机、泛型 ViewModel、预加载阈值 |
| 图片缓存 | URLCache、NSCache+磁盘混合、CachedAsyncImage、内存压力响应 |
| 深度链接路由 | URL Scheme+Universal Links 统一、Router+NavigationPath、延迟导航 |
| 统一错误处理 | AppError typed throws、isRetryable、ErrorAlertModifier |

### Swift 语言
Typed Throws、~Copyable、Parameter Packs、Data Race Safety、AsyncSequence、Regex、Swift Macros、Combine、Objective-C/C 互操作

## 使用方式

### Claude Code
将 `SKILL.md` 放在项目根目录，Claude Code 会自动加载。

### Cursor / Windsurf
将 `SKILL.md` 内容添加到项目的 Rules 或 Context 中。

### 其他 AI 工具
将 `SKILL.md` 作为系统提示或上下文文件提供给 AI 助手。

## 文件结构

```
.
├── README.md              # 本文件
├── SKILL.md               # 主知识库（7600+ 行）
└── apple_skills/          # 框架专题文件（详细参考）
    ├── apple_swiftui.md
    ├── apple_swift_language.md
    ├── apple_uikit.md
    ├── apple_avfoundation.md
    ├── apple_realitykit.md
    ├── apple_arkit.md
    ├── apple_vision.md
    ├── apple_wwdc25.md
    ├── apple_xcode.md
    └── ... (39 个框架专题文件)
```

## 统计

| 指标 | 数值 |
|------|------|
| SKILL.md 行数 | 7,600+ |
| 覆盖框架 | 45+ |
| 代码示例 | 1,000+ |
| 常见坑点 | 90 条 |
| 章节数 | 100+ |
| 支持平台 | iOS / iPadOS / macOS / visionOS / watchOS / tvOS |
| 目标版本 | iOS 26+ / Swift 6.2 / Xcode 26 |

## 更新日志

- **2026.04** — 全面更新至 iOS 26 / Swift 6.2 / Xcode 26
  - 新增 Liquid Glass 完整指南（基础 + 进阶 + UIKit + 可访问性）
  - 新增 Foundation Models Prompting 最佳实践 + Instruments 分析
  - 新增 SwiftData + CloudKit 完整同步指南 + 调试
  - 新增 watchOS / tvOS / visionOS 多平台开发
  - 新增 Xcode 调试、性能分析、测试完整指南
  - 新增 App Store Connect API + 发布分发流程
  - 新增 APNs HTTP/2 推送请求格式
  - 新增 MVVM + Repository + UseCase 架构模式
  - 新增依赖注入、分页/无限滚动、图片缓存、深度链接路由、统一错误处理
  - 新增 16 个框架进阶章节（Vision、ARKit、RealityKit、Network 等）
  - 坑点从 29 条扩展至 90 条

## License

MIT
