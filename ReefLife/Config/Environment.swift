//
//  Environment.swift
//  ReefLife
//
//  环境配置文件
//

import Foundation

/// 应用配置
/// 注意：在实际项目中，敏感信息应该从环境变量或 .xcconfig 文件读取
enum AppConfig {
    // MARK: - Supabase 配置

    /// Supabase 项目 URL
    static let supabaseURL = "https://dweqabfjfqlhaoomlkwq.supabase.co"

    /// Supabase Anon Key (公开密钥)
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR3ZXFhYmZqZnFsaGFvb21sa3dxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2MDQzMDcsImV4cCI6MjA4MzE4MDMwN30.PYNqo0to3sHquv0dMNMaa62EPl_XLYiExh7cDiQOWlk"

    /// OAuth 回调地址（需在 Supabase Auth 配置允许）
    static let authRedirectURL = URL(string: "reeflife://auth-callback")!

    // MARK: - 微信登录配置

    /// 微信 AppID（形如 wx123...）
    static let wechatAppId = "wxYOUR_APP_ID"

    /// 微信 AppSecret（建议放在服务端，不要在客户端存真实值）
    static let wechatAppSecret = "YOUR_WECHAT_APP_SECRET"

    /// 微信 Universal Link（需在微信开放平台配置）
    static let wechatUniversalLink = "https://example.com/app/"

    // MARK: - Cloudflare R2 配置

    /// R2 账户 ID
    static let r2AccountId = "c6fc8bcf3bba37f2611b6f3d7aad25b9"

    /// R2 访问密钥 ID
    static let r2AccessKeyId = "8d93b1b39ed3145a5d4df514e2d3fd01"

    /// R2 秘密访问密钥
    static let r2SecretAccessKey = "5d7d0fae75fc13b59d3bfa256c96609fb67f3fc0659be136881685f3034b398a"

    /// R2 存储桶名称
    static let r2BucketName = "reeflife-media"

    /// R2 公开访问 URL (使用 R2.dev 公开域名)
    static let r2PublicUrl = "https://pub-5279f11f5a334321a5d0156e2a00cb46.r2.dev"

    // MARK: - 应用信息

    /// 应用版本
    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    /// 构建号
    static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    // MARK: - 开发环境检测

    #if DEBUG
    static let isDebug = true
    #else
    static let isDebug = false
    #endif

    // MARK: - API 配置

    /// 默认分页大小
    static let defaultPageSize = 20

    /// 图片最大尺寸（字节）
    static let maxImageSize = 2 * 1024 * 1024  // 2MB

    /// 评论最大嵌套深度
    static let maxCommentDepth = 3
}

// MARK: - 表名常量
enum Tables {
    static let users = "users"
    static let posts = "posts"
    static let comments = "comments"
    static let channels = "channels"
    static let channelMembers = "channel_members"
    static let postVotes = "post_votes"
    static let postBookmarks = "post_bookmarks"
    static let commentLikes = "comment_likes"
    static let userFollows = "user_follows"
    static let species = "species"
    static let speciesFavorites = "species_favorites"
    static let notifications = "notifications"
    static let reports = "reports"
    static let media = "media"
    static let viewHistory = "view_history"
}

// MARK: - 视图常量
enum Views {
    static let postDetails = "post_details"
    static let commentDetails = "comment_details"
    static let trendingPosts = "trending_posts"
}

// MARK: - RPC 函数名
enum RPCFunctions {
    static let incrementViewCount = "increment_view_count"
    static let getUserStats = "get_user_stats"
    static let checkFollows = "check_follows"
    static let createNotification = "create_notification"
    static let markAllNotificationsRead = "mark_all_notifications_read"
}
