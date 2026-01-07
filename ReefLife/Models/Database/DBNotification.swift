//
//  DBNotification.swift
//  ReefLife
//
//  通知数据库模型
//

import Foundation

// MARK: - 通知数据库模型
struct DBNotification: Codable {
    let id: String
    let userId: String
    let type: String  // 数据库枚举
    let actorId: String?
    let postId: String?
    let commentId: String?
    let title: String?
    let body: String?
    let data: [String: AnyCodable]?
    let isRead: Bool
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, type, title, body, data
        case userId = "user_id"
        case actorId = "actor_id"
        case postId = "post_id"
        case commentId = "comment_id"
        case isRead = "is_read"
        case createdAt = "created_at"
    }

    /// 转换为领域模型
    func toDomain() -> AppNotification {
        AppNotification(
            id: id,
            userId: userId,
            type: mapTypeFromDB(type),
            actorId: actorId,
            postId: postId,
            commentId: commentId,
            title: title ?? "",
            body: body ?? "",
            isRead: isRead,
            createdAt: createdAt
        )
    }

    /// 类型映射
    private func mapTypeFromDB(_ dbType: String) -> NotificationType {
        switch dbType {
        case "like": return .like
        case "comment": return .comment
        case "reply": return .reply
        case "follow": return .follow
        case "mention": return .mention
        case "system": return .system
        default: return .system
        }
    }
}

// MARK: - 应用通知模型
struct AppNotification: Identifiable {
    let id: String
    let userId: String
    let type: NotificationType
    let actorId: String?
    let postId: String?
    let commentId: String?
    let title: String
    let body: String
    let isRead: Bool
    let createdAt: Date

    /// 相对时间
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}

// MARK: - 通知类型枚举
enum NotificationType: String, Codable {
    case like = "like"
    case comment = "comment"
    case reply = "reply"
    case follow = "follow"
    case mention = "mention"
    case system = "system"

    /// 图标名称
    var iconName: String {
        switch self {
        case .like: return "heart.fill"
        case .comment: return "bubble.left.fill"
        case .reply: return "arrowshape.turn.up.left.fill"
        case .follow: return "person.badge.plus.fill"
        case .mention: return "at"
        case .system: return "bell.fill"
        }
    }

    /// 颜色
    var iconColor: String {
        switch self {
        case .like: return "red"
        case .comment: return "blue"
        case .reply: return "green"
        case .follow: return "purple"
        case .mention: return "orange"
        case .system: return "gray"
        }
    }
}

// MARK: - 用户关注模型
struct DBUserFollow: Codable {
    let id: String?
    let followerId: String
    let followingId: String
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case followerId = "follower_id"
        case followingId = "following_id"
        case createdAt = "created_at"
    }
}

// MARK: - 媒体记录模型
struct DBMedia: Codable {
    let id: String?
    let userId: String
    let bucket: String
    let key: String
    let url: String
    let filename: String?
    let contentType: String?
    let sizeBytes: Int?
    let width: Int?
    let height: Int?
    let isProcessed: Bool?
    let thumbnailUrl: String?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, bucket, key, url, filename, width, height
        case userId = "user_id"
        case contentType = "content_type"
        case sizeBytes = "size_bytes"
        case isProcessed = "is_processed"
        case thumbnailUrl = "thumbnail_url"
        case createdAt = "created_at"
    }
}

// MARK: - 浏览历史模型
struct DBViewHistory: Codable {
    let id: String?
    let userId: String
    let postId: String?
    let speciesId: String?
    let viewedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case postId = "post_id"
        case speciesId = "species_id"
        case viewedAt = "viewed_at"
    }
}
