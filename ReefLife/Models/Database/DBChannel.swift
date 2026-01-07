//
//  DBChannel.swift
//  ReefLife
//
//  频道数据库模型
//

import Foundation

// MARK: - 频道数据库模型
struct DBChannel: Codable {
    let id: String
    let name: String
    let description: String?
    let imageUrl: String?
    let iconName: String?
    let category: String  // 数据库枚举类型
    let memberCount: Int
    let postCount: Int
    let isHot: Bool
    let isOfficial: Bool
    let isActive: Bool
    let createdAt: Date?
    let updatedAt: Date?
    let createdBy: String?
    let rules: [String]?

    enum CodingKeys: String, CodingKey {
        case id, name, description, category, rules
        case imageUrl = "image_url"
        case iconName = "icon_name"
        case memberCount = "member_count"
        case postCount = "post_count"
        case isHot = "is_hot"
        case isOfficial = "is_official"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case createdBy = "created_by"
    }

    /// 转换为领域模型
    func toDomain(isJoined: Bool = false) -> Channel {
        Channel(
            id: id,
            name: name,
            description: description ?? "",
            imageURL: imageUrl ?? "",
            memberCount: formatMemberCount(memberCount),
            onlineCount: 0,  // 需要通过 Realtime 获取
            isHot: isHot,
            iconName: iconName ?? "bubble.left.and.bubble.right",
            category: mapCategoryFromDB(category),
            isJoined: isJoined
        )
    }

    /// 格式化成员数量
    private func formatMemberCount(_ count: Int) -> String {
        if count >= 10000 {
            return String(format: "%.1fw", Double(count) / 10000)
        } else if count >= 1000 {
            return String(format: "%.1fk", Double(count) / 1000)
        } else {
            return "\(count)"
        }
    }

    /// 数据库分类映射
    private func mapCategoryFromDB(_ dbCategory: String) -> ChannelCategory {
        switch dbCategory {
        case "marine_life": return .creatures
        case "equipment": return .equipment
        case "marketplace": return .trading
        case "general": return .general
        default: return .general
        }
    }
}

// MARK: - 频道成员模型
struct DBChannelMember: Codable {
    let id: String?
    let channelId: String
    let userId: String
    let role: String
    let joinedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, role
        case channelId = "channel_id"
        case userId = "user_id"
        case joinedAt = "joined_at"
    }
}

// MARK: - 频道成员创建模型
struct DBChannelMemberCreate: Codable {
    let channelId: String
    let userId: String
    let role: String

    enum CodingKeys: String, CodingKey {
        case role
        case channelId = "channel_id"
        case userId = "user_id"
    }

    init(channelId: String, userId: String, role: String = "member") {
        self.channelId = channelId
        self.userId = userId
        self.role = role
    }
}
