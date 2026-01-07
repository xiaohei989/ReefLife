//
//  User.swift
//  ReefLife
//
//  用户数据模型
//

import Foundation

// MARK: - 用户模型
struct User: Identifiable, Codable, Hashable {
    let id: String
    let username: String
    let avatarURL: String
    let title: String              // 称号
    let bio: String                // 简介
    let postCount: Int
    let favoriteCount: Int
    let reputation: Int
    let replyCount: Int
    let joinedAt: Date
    let followersCount: Int
    let followingCount: Int
    let isVerified: Bool           // 是否已验证

    // MARK: - 初始化
    init(
        id: String = UUID().uuidString,
        username: String,
        avatarURL: String,
        title: String = "",
        bio: String = "",
        postCount: Int = 0,
        favoriteCount: Int = 0,
        reputation: Int = 0,
        replyCount: Int = 0,
        joinedAt: Date = Date(),
        followersCount: Int = 0,
        followingCount: Int = 0,
        isVerified: Bool = false
    ) {
        self.id = id
        self.username = username
        self.avatarURL = avatarURL
        self.title = title
        self.bio = bio
        self.postCount = postCount
        self.favoriteCount = favoriteCount
        self.reputation = reputation
        self.replyCount = replyCount
        self.joinedAt = joinedAt
        self.followersCount = followersCount
        self.followingCount = followingCount
        self.isVerified = isVerified
    }
}

// MARK: - 示例数据
extension User {
    static let sample = User(
        username: "OceanExplorer88",
        avatarURL: "https://lh3.googleusercontent.com/aida-public/AB6AXuAylINRuheiAvA0sUyjcdRjqGfaMkBtViAKT0IoKY1DgF4cwYi9nRDmTWGMhvPx-KUsa7HiqltiBFbKCVXoLKWLfBH9DcMllIS75-ijDS-GCd5vhQak2WjYu_4PylZb2JexixNx0Sl0oqxxj3gcQbOxBqURhbsoF-x8FyWEueXR-EMwDWN9Od-p2P4v6ZfmT-dQVFNvCxL867WBpdb4UTMq_jFegiEbzjvU36BLffqshAvarnmFyiKayw5VNfZGrXVJ_YbRcI9HYhlU",
        title: "珊瑚专家 | 礁岩大师",
        bio: "热爱海洋，专注SPS珊瑚养殖5年",
        postCount: 12,
        favoriteCount: 45,
        reputation: 120,
        replyCount: 85,
        followersCount: 256,
        followingCount: 48
    )
}
