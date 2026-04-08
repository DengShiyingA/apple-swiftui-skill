# Apple SwiftUI Development Skill

SwiftUI + Swift 6.2 + Xcode 26 + Apple Intelligence 生产级开发知识包。

专为 **Claude Code、Cursor、Windsurf** 等 AI 编程工具设计，让 AI 助手具备完整的 Apple 生态开发能力。

## 安装

把 `SKILL.md` 复制到你的 iOS 项目根目录，就完成了。

```bash
# 克隆
git clone https://github.com/DengShiyingA/apple-swiftui-skill.git

# 复制到你的项目
cp apple-swiftui-skill/SKILL.md ~/Projects/MyiOSApp/
```

各工具会自动识别：

| 工具 | 放置位置 |
|------|---------|
| **Claude Code** | 项目根目录 `SKILL.md` |
| **Cursor** | `.cursor/rules/SKILL.md` |
| **Windsurf** | `.windsurf/rules/SKILL.md` |
| **GitHub Copilot** | `.github/copilot-instructions.md` |
| **Xcode** | Settings → Coding Intelligence → Custom Instructions |

## 覆盖内容

**45+ 框架 · 1000+ 代码示例 · 90 条坑点 · 6 大平台**

| 分类 | 框架 |
|------|------|
| **UI** | SwiftUI、Liquid Glass、Charts、TipKit、PhotosPicker、ShareLink |
| **数据** | SwiftData、CloudKit、CoreData、UserDefaults、Keychain |
| **AI** | Foundation Models、CoreML、Vision、CreateML、NaturalLanguage |
| **AR/3D** | ARKit、RealityKit、SceneReconstruction、Room Tracking |
| **音视频** | AVFoundation、AVPlayer、HLS、SharePlay、Speech |
| **系统** | HealthKit、StoreKit 2、MapKit、CoreLocation、Network、EventKit、Contacts |
| **通知** | UserNotifications、APNs HTTP/2、Critical Alerts、Live Activities |
| **安全** | Sign in with Apple、Passkeys、CryptoKit、Face ID、Security Key |
| **平台** | watchOS、tvOS、visionOS、macOS |
| **工具** | Xcode 调试(ASan/TSan)、Instruments、Swift Testing、App Store Connect API |
| **架构** | MVVM+Repository、依赖注入、分页加载、图片缓存、深度链接路由、错误处理 |
| **语言** | Swift 6、Typed Throws、Macros、Combine、async/await、ObjC 互操作 |

## 文件结构

```
├── SKILL.md           # 主知识库（7,600+ 行）← 只需要这个文件
├── README.md          # 本文件
└── apple_skills/      # 39 个框架详细参考文件（可选）
```

## 更新

```bash
cd apple-swiftui-skill && git pull
```

## License

MIT
