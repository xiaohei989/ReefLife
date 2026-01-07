# ReefLife 后端配置指南

本指南将帮助你完成 Supabase 后端和 Cloudflare R2 存储的配置。

## 1. 添加 Supabase Swift SDK

### 在 Xcode 中添加依赖

1. 打开 `ReefLife.xcodeproj`
2. 选择项目 → `Package Dependencies`
3. 点击 `+` 按钮添加包
4. 输入 URL: `https://github.com/supabase/supabase-swift`
5. 选择版本: `2.0.0` 或更高
6. 点击 `Add Package`

### 添加的产品
- Supabase
- Auth
- Functions
- PostgREST
- Realtime
- Storage

## 2. 创建 Supabase 项目

### 2.1 注册并创建项目

1. 访问 [supabase.com](https://supabase.com)
2. 注册账号并创建新项目
3. 记录以下信息：
   - **Project URL**: `https://xxx.supabase.co`
   - **Anon Key**: `eyJxxxx...`

### 2.2 执行数据库 SQL

在 Supabase Dashboard 的 SQL Editor 中，按顺序执行以下文件：

1. `Database/schema.sql` - 创建表结构
2. `Database/triggers.sql` - 创建触发器和函数
3. `Database/rls_policies.sql` - 配置 RLS 安全策略

### 2.3 配置认证

#### Apple ID 登录
1. 进入 `Authentication` → `Providers`
2. 启用 `Apple`
3. 配置 Apple Developer 信息

#### 手机号登录
1. 进入 `Authentication` → `Providers`
2. 启用 `Phone`
3. 配置 Twilio 或其他短信服务商

## 3. 配置 Cloudflare R2

### 3.1 创建 R2 存储桶

1. 登录 Cloudflare Dashboard
2. 进入 `R2` 服务
3. 创建存储桶: `reeflife-media`

### 3.2 配置公开访问

1. 在存储桶设置中启用公开访问
2. 配置自定义域名（可选）: `media.reeflife.app`

### 3.3 创建 API Token

1. 进入 `R2` → `Manage R2 API Tokens`
2. 创建新 Token，权限选择 `Object Read & Write`
3. 记录：
   - **Account ID**
   - **Access Key ID**
   - **Secret Access Key**

## 4. 更新配置文件

编辑 `ReefLife/Config/Environment.swift`，填入你的配置：

```swift
enum Environment {
    // Supabase 配置
    static let supabaseURL = "https://your-project-id.supabase.co"
    static let supabaseAnonKey = "your-anon-key"

    // Cloudflare R2 配置
    static let r2AccountId = "your-account-id"
    static let r2AccessKeyId = "your-access-key-id"
    static let r2SecretAccessKey = "your-secret-access-key"
    static let r2BucketName = "reeflife-media"
    static let r2PublicUrl = "https://media.reeflife.app"
}
```

## 5. 将新文件添加到 Xcode 项目

在 Xcode 中，将以下新创建的文件夹添加到项目：

```
ReefLife/
├── Config/
│   └── Environment.swift
├── Core/
│   ├── Network/
│   │   └── SupabaseClient.swift
│   └── Services/
│       ├── AuthService.swift
│       ├── PostService.swift
│       ├── CommentService.swift
│       ├── ChannelService.swift
│       ├── SpeciesService.swift
│       ├── MediaService.swift
│       └── RealtimeService.swift
└── Models/
    ├── Database/
    │   ├── DBUser.swift
    │   ├── DBPost.swift
    │   ├── DBComment.swift
    │   ├── DBChannel.swift
    │   ├── DBSpecies.swift
    │   └── DBNotification.swift
    └── DTO/
        ├── CreatePostDTO.swift
        ├── CreateCommentDTO.swift
        └── UpdateUserDTO.swift
```

### 添加步骤
1. 在 Xcode 中右键点击 `ReefLife` 文件夹
2. 选择 `Add Files to "ReefLife"...`
3. 选择新创建的文件夹
4. 确保勾选 `Copy items if needed` 和 `Create groups`

## 6. 初始化数据

### 6.1 创建测试频道

在 Supabase SQL Editor 中执行：

```sql
INSERT INTO channels (name, description, category, icon_name, is_hot) VALUES
('小丑鱼乐园', '讨论各种小丑鱼的饲养心得', 'marine_life', 'fish', true),
('硬骨珊瑚 SPS', 'SPS 珊瑚爱好者交流区', 'marine_life', 'leaf', false),
('软体珊瑚 LPS', 'LPS 珊瑚饲养讨论', 'marine_life', 'leaf.fill', false),
('水质化学', '水质参数和化学讨论', 'equipment', 'flask', false),
('灯光与设备', '灯具和其他设备讨论', 'equipment', 'lightbulb', false),
('晒缸专区', '分享你的海水缸', 'general', 'camera', true),
('新手入门', '新手问题解答', 'general', 'questionmark.circle', true),
('生物交易', '海水生物交易', 'marketplace', 'cart', false);
```

### 6.2 导入物种数据

你可以编写脚本批量导入物种数据，或在应用中手动添加。

## 7. 测试连接

在 `ReefLifeApp.swift` 中添加测试代码：

```swift
import SwiftUI
import Supabase

@main
struct ReefLifeApp: App {
    init() {
        // 测试 Supabase 连接
        Task {
            do {
                let channels: [DBChannel] = try await SupabaseClientManager.shared.database
                    .from("channels")
                    .select()
                    .execute()
                    .value
                print("✅ Supabase 连接成功，获取到 \(channels.count) 个频道")
            } catch {
                print("❌ Supabase 连接失败: \(error)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

## 8. 下一步

配置完成后，你可以：

1. **对接 UI**: 将现有的 View 连接到服务层
2. **实现登录流程**: 创建登录/注册页面
3. **测试功能**: 逐个测试发帖、评论、点赞等功能
4. **集成微信登录**: 配置微信开放平台

## 常见问题

### Q: 编译报错找不到 Supabase 模块
A: 确保已正确添加 Swift Package 依赖，并重新构建项目

### Q: 数据库连接失败
A: 检查 `Environment.swift` 中的 URL 和 Key 是否正确

### Q: RLS 策略导致无法读取数据
A: 确保已正确执行 `rls_policies.sql`，并检查用户是否已登录

### Q: 图片上传失败
A: 检查 R2 配置是否正确，确保 API Token 有写入权限
