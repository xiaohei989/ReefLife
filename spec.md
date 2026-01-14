# ReefLife 产品规格说明书

> 最后更新: 2026-01-14

## 1. 项目概述

### 1.1 产品定位
ReefLife 是一款面向海水缸爱好者的社区应用，集社区交流、物种百科、二手交易于一体。

### 1.2 目标用户
| 用户类型 | 描述 |
|---------|------|
| 新手玩家 | 刚入门海水缸的玩家，需要学习和求助 |
| 资深玩家 | 有经验的爱好者，分享经验和交流 |
| 商业用户 | 水族店、养殖场等，进行商品展示和交易 |

### 1.3 目标平台
- **iOS** (iPhone/iPad) - SwiftUI 原生开发
- 最低支持版本: iOS 16.0

---

## 2. 技术架构

### 2.1 技术栈
| 层级 | 技术选型 |
|------|---------|
| 前端 | SwiftUI + Combine |
| 后端 | Supabase (PostgreSQL + Auth + Realtime) |
| 图片存储 | Cloudflare R2 |
| 推送服务 | APNs |

### 2.2 用户认证
- [x] Apple ID (Sign in with Apple)
- [x] 微信授权登录
- [x] 手机号验证码登录

---

## 3. 功能模块

### 3.1 首页 (Home)
| 功能 | 状态 | 说明 |
|------|------|------|
| 搜索栏 | ✅ UI完成 | 搜索鱼类、珊瑚或讨论 |
| 社区精选 | ✅ UI完成 | 4个精选入口卡片 |
| 最新热帖 | ✅ UI完成 | 帖子列表展示 |
| 通知入口 | ✅ UI完成 | 右上角铃铛图标 |

**已完成:**
- [x] 搜索功能实现（SearchResultsView + SearchViewModel）
- [x] 数据接口对接（HomeViewModel + PostService）
- [x] 下拉刷新/上拉加载（PaginationManager 分页管理）
- [x] 自动加载更多（滚动到底部触发）

### 3.2 社区 (Community)
| 功能 | 状态 | 说明 |
|------|------|------|
| 频道标签 | ✅ UI完成 | 硬骨SPS、软体LPS等分类 |
| 帖子列表 | ✅ UI完成 | 瀑布流展示 |
| 帖子详情 | ✅ UI完成 | 图片轮播、评论区 |
| 发帖入口 | ✅ UI完成 | 右下角悬浮按钮 |
| 频道详情 | ✅ UI完成 | 频道页面和筛选 |

**已完成:**
- [x] 发帖功能（CreatePostView + CreatePostViewModel，支持文字+图片+选择频道+标签）
- [x] 评论功能（评论提交、点赞、嵌套回复）
- [x] 点赞/踩功能（PostDetailView 投票交互）
- [x] 收藏功能（书签按钮交互）
- [x] 数据接口对接（CommunityViewModel + PostService + CommentService）
- [x] 下拉刷新/上拉加载（社区页和频道详情页）
- [x] 自动分页加载（统一的分页管理机制）

**待开发:**
- [ ] 举报/屏蔽功能

### 3.3 物种百科 (Encyclopedia)
| 功能 | 状态 | 说明 |
|------|------|------|
| 搜索栏 | ✅ UI完成 | 物种搜索 |
| 分类卡片 | ✅ UI完成 | SPS/LPS/鱼类/无脊椎 |
| 热门物种 | ✅ UI完成 | 横向滚动卡片 |
| 物种列表 | ✅ UI完成 | 分类浏览 |
| 物种详情 | ✅ UI完成 | 详细参数和饲养指南 |
| AI识别入口 | ✅ UI完成 | 拍照识别物种 |

**待开发:**
- [ ] AI物种识别功能
- [ ] 百科数据录入系统
- [ ] 用户贡献/纠错功能
- [ ] 搜索功能实现
- [ ] 数据接口对接

**数据来源:**
- 运营团队整理录入
- AI 辅助生成基础数据

### 3.4 个人中心 (Profile)
| 功能 | 状态 | 说明 |
|------|------|------|
| 用户信息 | ✅ UI完成 | 头像、昵称、等级 |
| 数据统计 | ✅ UI完成 | 发帖/收藏/声望/回复 |
| 我的收藏 | ✅ UI完成 | Tab切换 |
| 我的活动 | ✅ UI完成 | 动态时间线 |
| 设置入口 | ✅ UI完成 | 右上角齿轮图标 |

**已完成:**
- [x] 登录/注册页面（LoginView, RegisterView, PhoneLoginView）
- [x] 设置页面（SettingsView）
- [x] 登出功能

**待开发:**
- [ ] 编辑资料功能（图片上传）
- [ ] 数据接口对接（用户信息同步）

### 3.5 二手交易 (Trade) - 新模块
| 功能 | 状态 | 说明 |
|------|------|------|
| 商品列表 | ❌ 待开发 | C2C二手商品展示 |
| 商品详情 | ❌ 待开发 | 图片、价格、卖家信息 |
| 发布商品 | ❌ 待开发 | 拍照上传、定价 |
| 交易管理 | ❌ 待开发 | 订单状态跟踪 |

**交易模式:** C2C 二手交易（类似闲鱼）
**沟通方式:** 引导至微信沟通

---

## 4. 数据库设计 (Supabase)

### 4.1 核心表结构

```sql
-- 用户表
users (
  id, phone, wechat_id, apple_id,
  nickname, avatar_url, bio, level,
  created_at, updated_at
)

-- 帖子表
posts (
  id, author_id, channel_id,
  title, content, image_urls,
  upvotes, downvotes, comment_count,
  created_at, updated_at
)

-- 评论表
comments (
  id, post_id, author_id, parent_id,
  content, likes,
  created_at
)

-- 频道表
channels (
  id, name, description, icon,
  post_count, follower_count
)

-- 物种表
species (
  id, name, scientific_name, category,
  difficulty, description, image_url,
  care_guide, water_params,
  created_at, updated_at
)

-- 二手商品表
products (
  id, seller_id, title, description,
  price, image_urls, category,
  status, location, wechat_id,
  created_at, updated_at
)
```

---

## 5. 开发进度

### 5.1 已完成 (Phase 1 - UI)
- [x] 项目架构搭建
- [x] 设计系统 (Colors, Typography, Spacing)
- [x] 公共组件 (SearchBar, TagChip, SpeciesCard, PostCard, AvatarView)
- [x] 首页 UI
- [x] 社区页 UI
- [x] 百科页 UI
- [x] 个人中心 UI
- [x] 自定义 TabBar（带动画）

### 5.2 已完成 (Phase 2 - 后端接入)
- [x] Supabase 项目配置
- [x] 数据库表创建（users, posts, comments, channels, species, bookmarks, post_votes）
- [x] 图片上传 (Cloudflare R2 + MediaService)
- [x] 数据服务层（SupabaseService, PostService, CommentService, ChannelService, SpeciesService）

### 5.3 已完成 (Phase 3 - 核心功能)
- [x] 发帖功能（CreatePostView + CreatePostViewModel）
- [x] 评论功能（评论提交、点赞、嵌套回复）
- [x] 点赞/收藏功能（投票、书签完整交互）
- [x] 搜索功能（SearchResultsView + SearchViewModel）

### 5.4 已完成 (Phase 3.5 - 用户系统)
- [x] 用户注册/登录（LoginView, RegisterView, PhoneLoginView）
- [x] Auth 认证集成（AuthService, AuthViewModel, AppState）
- [x] 登出功能（SettingsView 退出登录）

### 5.5 未来计划 (Phase 4 - 扩展功能)
- [ ] 二手交易模块
- [ ] AI物种识别
- [ ] 推送通知
- [ ] 举报/审核系统

---

## 6. 时间规划

| 阶段 | 内容 | 预计时间 |
|------|------|---------|
| Phase 2 | 后端接入 + 用户认证 | 1周 |
| Phase 3 | 社区核心功能 | 2周 |
| Phase 4 | 二手交易 MVP | 1周 |
| **上线** | **MVP 版本** | **1个月内** |

---

## 7. 文件结构

```
ReefLife/
├── App/
│   └── ReefLifeApp.swift
├── Core/
│   ├── Design/
│   │   ├── Colors.swift
│   │   ├── Typography.swift
│   │   ├── Spacing.swift
│   │   └── Components/
│   │       ├── SearchBar.swift
│   │       ├── TagChip.swift
│   │       ├── SpeciesCard.swift
│   │       ├── PostCard.swift
│   │       └── AvatarView.swift
│   └── Extensions/
│       └── View+Extensions.swift
├── Features/
│   ├── Home/
│   │   ├── HomeView.swift
│   │   └── HomeViewModel.swift
│   ├── Auth/
│   │   ├── AuthViewModel.swift          # 认证状态管理
│   │   ├── LoginView.swift              # 登录页面
│   │   ├── RegisterView.swift           # 注册页面
│   │   └── PhoneLoginView.swift         # 手机号登录
│   ├── Community/
│   │   ├── CommunityHomeView.swift      # 包含 PostDetailView, SearchResultsView
│   │   ├── CommunityViewModel.swift     # 包含多个 ViewModel
│   │   ├── CreatePostView.swift         # 发帖页面
│   │   ├── ChannelDetailView.swift
│   │   └── ChannelListView.swift
│   ├── Encyclopedia/
│   │   ├── EncyclopediaHomeView.swift
│   │   └── EncyclopediaViewModel.swift
│   ├── Profile/
│   │   └── ProfileView.swift
│   └── Trade/               # 待创建
├── Models/
│   ├── User.swift
│   ├── Post.swift
│   ├── Comment.swift
│   ├── Channel.swift
│   └── Species.swift
├── Navigation/
│   └── MainTabView.swift
├── Services/
│   ├── SupabaseService.swift
│   ├── AuthService.swift
│   ├── PostService.swift
│   ├── CommentService.swift
│   ├── ChannelService.swift
│   ├── SpeciesService.swift
│   └── MediaService.swift
└── Resources/
    └── Assets.xcassets/
```

---

## 8. 注意事项

### 8.1 安全要求
- 敏感信息不得硬编码
- API Key 使用环境变量或 Keychain
- 用户密码使用 Supabase Auth 托管

### 8.2 性能要求
- 图片懒加载 + 缓存
- 列表分页加载
- 离线数据缓存

### 8.3 审核合规
- Apple 登录为必选项 (App Store 要求)
- 用户内容需要审核机制
- 隐私政策和用户协议
