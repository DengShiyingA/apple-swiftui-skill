# Apple SwiftUI Development Skill

SwiftUI + Swift 6.2 + Xcode 26 + Apple Intelligence 生产级开发知识包。

专为 **Claude Code、Cursor、Windsurf、Xcode Coding Intelligence** 等 AI 编程工具设计的 Skill 文件，让 AI 助手具备完整的 Apple 生态开发能力。

---

## 快速开始

### 1. 克隆仓库

```bash
git clone https://github.com/DengShiyingA/apple-swiftui-skill.git
```

### 2. 选择你的 AI 工具，按以下方式安装

---

## 安装指南

### Claude Code（CLI / Desktop / Web）

Claude Code 支持自动加载项目根目录的 Skill 文件。

**方式 A：直接放入项目（推荐）**

```bash
# 进入你的 iOS 项目目录
cd ~/Projects/MyiOSApp

# 复制 SKILL.md 到项目根目录
cp ~/apple-swiftui-skill/SKILL.md .

# 创建 .claude/settings.json（如果不存在）
mkdir -p .claude
cat > .claude/settings.json << 'EOF'
{
  "skills": ["SKILL.md"]
}
EOF
```

**方式 B：全局安装（所有项目共享）**

```bash
# 创建全局 Claude 配置目录
mkdir -p ~/.claude

# 复制到全局位置
cp ~/apple-swiftui-skill/SKILL.md ~/.claude/

# 在全局 settings.json 中注册
cat > ~/.claude/settings.json << 'EOF'
{
  "skills": ["~/.claude/SKILL.md"]
}
EOF
```

**方式 C：Git Submodule（团队共享，自动更新）**

```bash
cd ~/Projects/MyiOSApp

# 添加为子模块
git submodule add https://github.com/DengShiyingA/apple-swiftui-skill.git .skills

# 在 .claude/settings.json 中引用
mkdir -p .claude
cat > .claude/settings.json << 'EOF'
{
  "skills": [".skills/SKILL.md"]
}
EOF

# 团队成员克隆后执行
git submodule update --init
```

**验证安装**：启动 Claude Code，输入 "SwiftUI NavigationStack 怎么用"，如果 AI 回复包含 iOS 26 最新 API 和 Liquid Glass，说明 Skill 已加载。

---

### Cursor

**方式 A：项目级 Rules（推荐）**

```bash
cd ~/Projects/MyiOSApp

# 创建 .cursor/rules 目录
mkdir -p .cursor/rules

# 复制 Skill 文件
cp ~/apple-swiftui-skill/SKILL.md .cursor/rules/swiftui-skill.md
```

Cursor 会自动加载 `.cursor/rules/` 下的所有 `.md` 文件作为上下文。

**方式 B：全局 Rules**

1. 打开 Cursor → Settings → General → Rules for AI
2. 点击 "Add Rule File"
3. 选择 `SKILL.md` 文件

**方式 C：手动添加到对话上下文**

1. 在 Cursor 的 Chat 面板中
2. 点击 "+" 或 "@" 按钮
3. 选择 "File" → 浏览并选择 `SKILL.md`

---

### Windsurf

```bash
cd ~/Projects/MyiOSApp

# 创建 .windsurf/rules 目录
mkdir -p .windsurf/rules

# 复制 Skill 文件
cp ~/apple-swiftui-skill/SKILL.md .windsurf/rules/swiftui-skill.md
```

Windsurf 自动加载 `.windsurf/rules/` 目录下的规则文件。

---

### Xcode（Coding Intelligence）

Xcode 26 的 Coding Intelligence 支持项目级自定义指令：

```bash
cd ~/Projects/MyiOSApp

# 创建 Xcode 自定义指令文件
cp ~/apple-swiftui-skill/SKILL.md .github/instructions.md
```

或在 Xcode 中：Settings → Coding Intelligence → Custom Instructions → 粘贴 SKILL.md 内容。

---

### GitHub Copilot

```bash
cd ~/Projects/MyiOSApp

# 创建 GitHub Copilot 指令文件
mkdir -p .github
cp ~/apple-swiftui-skill/SKILL.md .github/copilot-instructions.md
```

GitHub Copilot 会自动加载 `.github/copilot-instructions.md` 作为项目级上下文。

---

### 其他 AI 工具（通用方式）

对于任何支持自定义系统提示的 AI 工具：

1. 打开 SKILL.md
2. 复制全部内容
3. 粘贴到工具的 "System Prompt"、"Custom Instructions" 或 "Context" 设置中

> **注意**：SKILL.md 有 7600+ 行，部分工具可能有字符限制。如果超出限制，可以只使用你需要的章节。

---

## 项目结构

```
apple-swiftui-skill/
├── README.md                          # 本文件（安装指南 + 使用说明）
├── SKILL.md                           # 主知识库（7,600+ 行，核心文件）
└── apple_skills/                      # 框架专题详细参考文件
    ├── apple_swiftui.md               #   SwiftUI 详细文档
    ├── apple_swift_language.md         #   Swift 语言完整参考
    ├── apple_uikit.md                 #   UIKit 框架
    ├── apple_avfoundation.md          #   AVFoundation 音视频
    ├── apple_realitykit.md            #   RealityKit 3D/AR
    ├── apple_arkit.md                 #   ARKit 增强现实
    ├── apple_vision.md                #   Vision 图像识别
    ├── apple_coreml.md                #   CoreML 机器学习
    ├── apple_swiftdata.md             #   SwiftData 持久化
    ├── apple_coredata.md              #   CoreData 框架
    ├── apple_cloudkit.md              #   CloudKit 云同步
    ├── apple_healthkit.md             #   HealthKit 健康数据
    ├── apple_storekit.md              #   StoreKit 内购订阅
    ├── apple_widgetkit.md             #   WidgetKit 小组件
    ├── apple_appintents.md            #   App Intents / Siri
    ├── apple_usernotifications.md     #   推送通知
    ├── apple_mapkit.md                #   MapKit 地图
    ├── apple_network.md               #   Network 框架
    ├── apple_corelocation.md          #   CoreLocation 定位
    ├── apple_corebluetooth.md         #   CoreBluetooth 蓝牙
    ├── apple_coremotion.md            #   CoreMotion 运动传感器
    ├── apple_coreimage.md             #   CoreImage 图像处理
    ├── apple_createml.md              #   CreateML 模型训练
    ├── apple_eventkit.md              #   EventKit 日历
    ├── apple_contacts.md              #   Contacts 通讯录
    ├── apple_safariservices.md        #   Safari / OAuth
    ├── apple_authenticationservices.md #   认证服务
    ├── apple_passkit.md               #   Apple Pay
    ├── apple_naturallanguage.md       #   NaturalLanguage NLP
    ├── apple_combine.md               #   Combine 响应式
    ├── apple_spritekit.md             #   SpriteKit 2D 游戏
    ├── apple_webkit.md                #   WebKit 网页
    ├── apple_backgroundtasks.md       #   后台任务
    ├── apple_coregraphics.md          #   CoreGraphics 绘图
    ├── apple_foundation.md            #   Foundation 基础
    ├── apple_swift.md                 #   Swift 语言特性
    ├── apple_wwdc25.md                #   WWDC25 新特性
    └── apple_xcode.md                 #   Xcode 工具链
```

### 文件说明

| 文件 | 用途 | 大小 |
|------|------|------|
| `SKILL.md` | **核心文件** — AI 工具加载此文件即可获得完整能力 | 7,600+ 行 |
| `apple_skills/*.md` | **参考文件** — 每个框架的详细文档，供深入查阅 | 总计 103,000+ 行 |

> **提示**：大多数场景只需要 `SKILL.md` 一个文件。`apple_skills/` 目录是更详细的参考资料，适合需要深入某个框架时查阅。

---

## 你可能还需要创建的文件

在你的 iOS 项目中，配合本 Skill 使用时，建议创建以下文件：

### 1. `CLAUDE.md`（Claude Code 项目指令）

在 iOS 项目根目录创建，告诉 Claude Code 项目的具体情况：

```markdown
# Project Instructions

## 项目信息
- App 名称：MyApp
- 最低部署版本：iOS 26.0
- 语言：Swift 6.2
- UI 框架：SwiftUI（纯 SwiftUI，不使用 UIKit）
- 数据持久化：SwiftData + CloudKit
- 架构：MVVM + Repository + UseCase
- 包管理：Swift Package Manager

## 代码规范
- 所有 ViewModel 使用 @MainActor @Observable
- 网络请求使用 async/await，不使用 Combine
- 错误处理使用 typed throws (throws(AppError))
- 依赖注入使用构造器注入
- 测试使用 Swift Testing（不使用 XCTest）

## 项目结构
```
MyApp/
├── App/                    # @main App 入口
├── Features/               # 按功能模块组织
│   ├── Home/
│   │   ├── HomeView.swift
│   │   └── HomeViewModel.swift
│   ├── Article/
│   └── Settings/
├── Domain/                 # 业务逻辑层
│   ├── UseCases/
│   ├── Repositories/       # Repository 协议
│   └── Models/
├── Data/                   # 数据层
│   ├── Repositories/       # Repository 实现
│   ├── DataSources/
│   └── SwiftData/          # @Model 类
├── Core/                   # 基础设施
│   ├── DI/                 # 依赖注入容器
│   ├── Network/            # URLSession 封装
│   ├── Cache/              # 图片缓存等
│   ├── Router/             # 深度链接路由
│   └── Extensions/
└── Resources/
```

## 常用命令
- 运行测试：`xcodebuild test -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 16'`
- 构建：`xcodebuild build -scheme MyApp`
```

### 2. `.cursorrules`（Cursor 项目规则）

```markdown
You are an expert iOS developer using SwiftUI, Swift 6.2, and Xcode 26.

Rules:
- Always use @Observable instead of ObservableObject
- Always use SwiftData instead of CoreData for new models
- Always use Swift Testing (@Test) instead of XCTest for new tests
- Always use async/await instead of completion handlers
- Always use NavigationStack instead of NavigationView
- Use Liquid Glass (.glassEffect) for custom controls on iOS 26
- Wrap multiple glassEffect in GlassEffectContainer
- Use typed throws (throws(AppError)) for error handling
- Mark all ViewModels with @MainActor @Observable
- Use #Preview instead of PreviewProvider
```

### 3. `.windsurfrules`（Windsurf 项目规则）

内容同上 `.cursorrules`，放在 `.windsurf/rules/` 目录下。

### 4. `SKILL.md` 的精简版本（可选）

如果你的 AI 工具有 token 限制，可以创建一个只包含你需要的章节的精简版：

```bash
# 提取特定章节（例如只要 SwiftUI + SwiftData + Foundation Models）
head -500 SKILL.md > SKILL-lite.md
```

---

## 使用技巧

### 触发 Skill 的正确方式

Skill 通过关键词触发。以下是一些有效的提问方式：

```
✅ "用 SwiftUI 写一个带 Liquid Glass 效果的导航栏"
✅ "SwiftData 怎么配置 CloudKit 同步"
✅ "帮我实现一个带分页加载的文章列表"
✅ "Foundation Models 怎么做 Guided Generation"
✅ "写一个完整的 MVVM + Repository 架构"
✅ "ARKit LiDAR 深度扫描怎么实现"
✅ "配置 APNs HTTP/2 推送"

❌ "帮我写个 App"（太模糊，无法触发具体知识）
```

### 搭配 apple_skills/ 深入查阅

当 AI 基于 SKILL.md 给出的回答需要更多细节时：

```
"关于 AVFoundation 相机拍摄，请参考 apple_skills/apple_avfoundation.md 给出更详细的实现"
```

### 保持更新

```bash
# 如果使用 git clone
cd apple-swiftui-skill && git pull

# 如果使用 submodule
cd MyiOSApp && git submodule update --remote .skills
```

---

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

---

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

## 常见问题

### Q: SKILL.md 太大了，AI 工具加载不了怎么办？
A: 大多数现代 AI 工具（Claude Code、Cursor、Windsurf）都支持大文件。如果确实超出限制，可以只复制你需要的章节。

### Q: 如何确认 Skill 已经被 AI 加载？
A: 问一个只有 Skill 中才有的知识，例如 "iOS 26 的 Liquid Glass glassEffectUnion 怎么用"。如果 AI 能准确回答，说明已加载。

### Q: 可以只用 apple_skills/ 下的单个文件吗？
A: 可以。每个文件都是独立的框架参考。但 SKILL.md 是精华汇总，推荐优先使用。

### Q: 需要 Xcode 26 才能用吗？
A: SKILL.md 的内容以 iOS 26 / Xcode 26 为目标，但大部分 API 在 iOS 17-18 也适用。每个代码示例都注明了最低版本要求。

### Q: 团队怎么共享？
A: 推荐用 Git Submodule 方式，所有团队成员自动获取最新版本。

---

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
