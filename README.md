# Apple SwiftUI Development Skill

SwiftUI + Swift 6.2 + Xcode 26 + Apple Intelligence 生产级开发知识包。

专为 **Claude Code、Cursor、Windsurf** 等 AI 编程工具设计，让 AI 助手具备完整的 Apple 生态开发能力。

## 安装

### Claude Code

**第 1 步**：克隆仓库

```bash
git clone https://github.com/DengShiyingA/apple-swiftui-skill.git
```

**第 2 步**：复制 `SKILL.md` 到你的 iOS 项目根目录

```bash
cp /path/to/apple-swiftui-skill/SKILL.md ~/Projects/MyiOSApp/
```

完成。Claude Code 打开项目时会自动加载 `SKILL.md`。

---

### Cursor

**第 1 步**：克隆仓库（同上）

**第 2 步**：在你的 iOS 项目中创建 `.cursor/rules/` 目录，把 `SKILL.md` 放进去

```bash
cd ~/Projects/MyiOSApp
mkdir -p .cursor/rules
cp /path/to/apple-swiftui-skill/SKILL.md .cursor/rules/
```

完成。Cursor 会自动加载 `.cursor/rules/` 下的所有文件。

---

### Windsurf

**第 1 步**：克隆仓库（同上）

**第 2 步**：在你的 iOS 项目中创建 `.windsurf/rules/` 目录，把 `SKILL.md` 放进去

```bash
cd ~/Projects/MyiOSApp
mkdir -p .windsurf/rules
cp /path/to/apple-swiftui-skill/SKILL.md .windsurf/rules/
```

完成。Windsurf 会自动加载。

---

### GitHub Copilot

**第 1 步**：克隆仓库（同上）

**第 2 步**：复制为 `.github/copilot-instructions.md`

```bash
cd ~/Projects/MyiOSApp
mkdir -p .github
cp /path/to/apple-swiftui-skill/SKILL.md .github/copilot-instructions.md
```

完成。Copilot 会自动读取这个文件。

---

### Xcode Coding Intelligence

1. 打开 Xcode → Settings → Coding Intelligence
2. 在 Custom Instructions 中粘贴 `SKILL.md` 的内容

---

### 验证是否生效

安装后问 AI 一个问题测试：

```
"iOS 26 的 Liquid Glass glassEffectUnion 怎么用？"
```

如果 AI 能准确回答（包含 `GlassEffectContainer`、`@Namespace` 等细节），说明已生效。

## 更新

```bash
cd /path/to/apple-swiftui-skill && git pull
```

然后重新复制 `SKILL.md` 到你的项目。

## 仓库自检

```bash
./scripts/validate-skill-repo.sh
```

这个脚本会检查：
- `SKILL.md` 的 frontmatter 描述是否符合技能发现规则
- `README.md` 中声明的仓库结构是否与实际文件一致

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

## 文件说明

```
├── SKILL.md           # 主知识库（7,600+ 行）← 只需要这个文件
├── README.md          # 本文件
└── scripts/
   └── validate-skill-repo.sh   # 仓库说明与 skill 元数据校验
```

## License

MIT
