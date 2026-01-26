//
//  DBPost.swift
//  ReefLife
//
//  帖子数据库模型
//

import Foundation

// MARK: - 帖子数据库模型
struct DBPost: Codable {
    let id: String?
    let authorId: String
    let channelId: String
    let title: String
    let content: String
    let imageUrls: [String]
    let tags: [String]
    let upvotes: Int?
    let downvotes: Int?
    let commentCount: Int?
    let viewCount: Int?
    let bookmarkCount: Int?
    let isPinned: Bool?
    let isFeatured: Bool?
    let isLocked: Bool?
    let isDeleted: Bool?
    let createdAt: Date?
    let updatedAt: Date?
    let lastActivityAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, title, content, tags, upvotes, downvotes
        case authorId = "author_id"
        case channelId = "channel_id"
        case imageUrls = "image_urls"
        case commentCount = "comment_count"
        case viewCount = "view_count"
        case bookmarkCount = "bookmark_count"
        case isPinned = "is_pinned"
        case isFeatured = "is_featured"
        case isLocked = "is_locked"
        case isDeleted = "is_deleted"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case lastActivityAt = "last_activity_at"
    }
}

// MARK: - 帖子详情视图模型（包含关联数据）
struct DBPostDetail: Codable {
    let id: String
    let authorId: String?
    let channelId: String?
    let title: String?
    let content: String?
    let imageUrls: [String]?
    let tags: [String]?
    let upvotes: Int?
    let downvotes: Int?
    let commentCount: Int?
    let viewCount: Int?
    let bookmarkCount: Int?
    let isPinned: Bool?
    let isFeatured: Bool?
    let isLocked: Bool?
    let createdAt: Date?
    let updatedAt: Date?
    let lastActivityAt: Date?

    // 关联数据
    let authorName: String?
    let authorAvatar: String?
    let authorTitle: String?
    let channelName: String?
    let channelIcon: String?

    enum CodingKeys: String, CodingKey {
        case id, title, content, tags, upvotes, downvotes
        case authorId = "author_id"
        case channelId = "channel_id"
        case imageUrls = "image_urls"
        case commentCount = "comment_count"
        case viewCount = "view_count"
        case bookmarkCount = "bookmark_count"
        case isPinned = "is_pinned"
        case isFeatured = "is_featured"
        case isLocked = "is_locked"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case lastActivityAt = "last_activity_at"
        case authorName = "author_name"
        case authorAvatar = "author_avatar"
        case authorTitle = "author_title"
        case channelName = "channel_name"
        case channelIcon = "channel_icon"
    }

    /// 转换为领域模型
    func toDomain(userVote: Int? = nil, isBookmarked: Bool = false) -> Post {
        Post(
            id: id,
            authorId: authorId ?? "",
            authorName: authorName ?? "未知用户",
            authorAvatar: authorAvatar ?? "",
            channelId: channelId ?? "",
            channelName: channelName ?? "未知频道",
            title: title ?? "",
            content: content ?? "",
            imageURLs: imageUrls ?? [],
            tags: (tags ?? []).compactMap { PostTag(rawValue: mapTagFromDB($0)) },
            upvotes: upvotes ?? 0,
            downvotes: downvotes ?? 0,
            commentCount: commentCount ?? 0,
            createdAt: createdAt ?? Date(),
            isBookmarked: isBookmarked
        )
    }

    /// 数据库标签映射到应用标签
    private func mapTagFromDB(_ dbTag: String) -> String {
        switch dbTag {
        case "show_tank": return "晒缸"
        case "discussion": return "讨论"
        case "help": return "求助"
        case "encyclopedia": return "百科"
        case "fun_facts": return "趣闻"
        default: return dbTag
        }
    }
}

// MARK: - 帖子投票模型
struct DBPostVote: Codable {
    let id: String?
    let postId: String
    let userId: String
    let voteType: Int  // 1 = upvote, -1 = downvote
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case postId = "post_id"
        case userId = "user_id"
        case voteType = "vote_type"
        case createdAt = "created_at"
    }
}

// MARK: - 帖子收藏模型
struct DBPostBookmark: Codable {
    let id: String?
    let postId: String
    let userId: String
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case postId = "post_id"
        case userId = "user_id"
        case createdAt = "created_at"
    }
}

// MARK: - 帖子创建模型
struct DBPostCreate: Codable {
    let authorId: String
    let channelId: String
    let title: String
    let content: String
    let imageUrls: [String]
    let tags: [String]

    enum CodingKeys: String, CodingKey {
        case title, content, tags
        case authorId = "author_id"
        case channelId = "channel_id"
        case imageUrls = "image_urls"
    }
}
