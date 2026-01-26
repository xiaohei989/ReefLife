//
//  DBComment.swift
//  ReefLife
//
//  评论数据库模型
//

import Foundation

// MARK: - 评论数据库模型
struct DBComment: Codable {
    let id: String?
    let postId: String
    let authorId: String
    let parentId: String?
    let content: String
    let likes: Int?
    let replyCount: Int?
    let isDeleted: Bool?
    let createdAt: Date?
    let updatedAt: Date?
    let depth: Int?
    let path: [String]?

    enum CodingKeys: String, CodingKey {
        case id, content, likes, depth, path
        case postId = "post_id"
        case authorId = "author_id"
        case parentId = "parent_id"
        case replyCount = "reply_count"
        case isDeleted = "is_deleted"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - 评论详情视图模型
struct DBCommentDetail: Codable {
    let id: String
    let postId: String?
    let authorId: String?
    let parentId: String?
    let content: String?
    let likes: Int?
    let replyCount: Int?
    let isDeleted: Bool?
    let createdAt: Date?
    let updatedAt: Date?
    let depth: Int?
    let path: [String]?  // 添加缺失字段
    let authorName: String?
    let authorAvatar: String?
    let authorTitle: String?

    enum CodingKeys: String, CodingKey {
        case id, content, likes, depth, path
        case postId = "post_id"
        case authorId = "author_id"
        case parentId = "parent_id"
        case replyCount = "reply_count"
        case isDeleted = "is_deleted"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case authorName = "author_name"
        case authorAvatar = "author_avatar"
        case authorTitle = "author_title"
    }

    /// 转换为领域模型
    func toDomain(isLiked: Bool = false, replies: [Comment] = []) -> Comment {
        return Comment(
            id: id,
            postId: postId ?? "",
            authorId: authorId ?? "",
            authorName: authorName ?? "未知用户",
            authorAvatar: authorAvatar ?? "",
            content: content ?? "",
            likes: likes ?? 0,
            createdAt: createdAt ?? Date(),
            replies: replies
        )
    }
}

// MARK: - 评论点赞模型
struct DBCommentLike: Codable {
    let id: String?
    let commentId: String
    let userId: String?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case commentId = "comment_id"
        case userId = "user_id"
        case createdAt = "created_at"
    }
}

// MARK: - 评论创建模型
struct DBCommentCreate: Codable {
    let postId: String
    let authorId: String
    let parentId: String?
    let content: String

    enum CodingKeys: String, CodingKey {
        case content
        case postId = "post_id"
        case authorId = "author_id"
        case parentId = "parent_id"
    }
}
