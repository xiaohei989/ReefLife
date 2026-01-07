//
//  DBUser.swift
//  ReefLife
//
//  用户数据库模型
//

import Foundation

// MARK: - 用户数据库模型
struct DBUser: Codable {
    let id: String
    let username: String
    let avatarUrl: String?
    let title: String
    let bio: String
    let postCount: Int
    let favoriteCount: Int
    let reputation: Int
    let replyCount: Int
    let joinedAt: Date
    let followersCount: Int
    let followingCount: Int
    let isVerified: Bool
    let isBanned: Bool
    let settings: [String: AnyCodable]?
    let updatedAt: Date?
    let lastActiveAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, username, title, bio, reputation, settings
        case avatarUrl = "avatar_url"
        case postCount = "post_count"
        case favoriteCount = "favorite_count"
        case replyCount = "reply_count"
        case joinedAt = "joined_at"
        case followersCount = "followers_count"
        case followingCount = "following_count"
        case isVerified = "is_verified"
        case isBanned = "is_banned"
        case updatedAt = "updated_at"
        case lastActiveAt = "last_active_at"
    }

    /// 转换为领域模型
    func toDomain() -> User {
        User(
            id: id,
            username: username,
            avatarURL: avatarUrl ?? "",
            title: title,
            bio: bio,
            postCount: postCount,
            favoriteCount: favoriteCount,
            reputation: reputation,
            replyCount: replyCount,
            joinedAt: joinedAt,
            followersCount: followersCount,
            followingCount: followingCount
        )
    }
}

// MARK: - 用户更新模型
struct DBUserUpdate: Codable {
    var username: String?
    var avatarUrl: String?
    var title: String?
    var bio: String?
    var settings: [String: AnyCodable]?

    enum CodingKeys: String, CodingKey {
        case username, title, bio, settings
        case avatarUrl = "avatar_url"
    }
}
