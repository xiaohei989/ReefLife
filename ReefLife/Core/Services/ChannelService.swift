//
//  ChannelService.swift
//  ReefLife
//
//  频道服务 - 处理频道的查询、加入、离开等操作
//

import Foundation
import Supabase

// MARK: - 频道服务协议
protocol ChannelServiceProtocol {
    func getChannels(category: ChannelCategory?) async throws -> [Channel]
    func getHotChannels(limit: Int) async throws -> [Channel]
    func getChannel(id: String) async throws -> Channel
    func joinChannel(id: String) async throws
    func leaveChannel(id: String) async throws
    func getJoinedChannels() async throws -> [Channel]
    func searchChannels(query: String) async throws -> [Channel]
}

// MARK: - 频道服务实现
final class ChannelService: ChannelServiceProtocol {
    /// 单例实例
    static let shared = ChannelService()

    private let supabase = SupabaseClientManager.shared

    private init() {}

    // MARK: - 获取频道列表

    func getChannels(category: ChannelCategory? = nil) async throws -> [Channel] {
        var query = supabase.database
            .from(Tables.channels)
            .select()
            .eq("is_active", value: true)

        if let category = category {
            let dbCategory = mapCategoryToDB(category)
            query = query.eq("category", value: dbCategory)
        }

        let response: [DBChannel] = try await query
            .order("member_count", ascending: false)
            .execute()
            .value

        // 获取用户加入状态
        return try await enrichChannelsWithJoinState(response)
    }

    // MARK: - 获取热门频道

    func getHotChannels(limit: Int = 10) async throws -> [Channel] {
        let response: [DBChannel] = try await supabase.database
            .from(Tables.channels)
            .select()
            .eq("is_active", value: true)
            .eq("is_hot", value: true)
            .order("member_count", ascending: false)
            .limit(limit)
            .execute()
            .value

        return try await enrichChannelsWithJoinState(response)
    }

    // MARK: - 获取单个频道

    func getChannel(id: String) async throws -> Channel {
        let response: DBChannel = try await supabase.database
            .from(Tables.channels)
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value

        let channels = try await enrichChannelsWithJoinState([response])
        return channels.first!
    }

    // MARK: - 加入频道

    func joinChannel(id: String) async throws {
        guard let userId = supabase.currentUserId else {
            throw ChannelError.unauthorized
        }

        let member = DBChannelMemberCreate(
            channelId: id,
            userId: userId
        )

        try await supabase.database
            .from(Tables.channelMembers)
            .insert(member)
            .execute()
    }

    // MARK: - 离开频道

    func leaveChannel(id: String) async throws {
        guard let userId = supabase.currentUserId else {
            throw ChannelError.unauthorized
        }

        try await supabase.database
            .from(Tables.channelMembers)
            .delete()
            .eq("channel_id", value: id)
            .eq("user_id", value: userId)
            .execute()
    }

    // MARK: - 获取已加入的频道

    func getJoinedChannels() async throws -> [Channel] {
        guard let userId = supabase.currentUserId else {
            throw ChannelError.unauthorized
        }

        // 获取成员记录
        let members: [DBChannelMember] = try await supabase.database
            .from(Tables.channelMembers)
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value

        let channelIds = members.map { $0.channelId }

        if channelIds.isEmpty {
            return []
        }

        // 获取频道详情
        let response: [DBChannel] = try await supabase.database
            .from(Tables.channels)
            .select()
            .in("id", values: channelIds)
            .execute()
            .value

        return response.map { $0.toDomain(isJoined: true) }
    }

    // MARK: - 搜索频道

    func searchChannels(query: String) async throws -> [Channel] {
        let response: [DBChannel] = try await supabase.database
            .from(Tables.channels)
            .select()
            .eq("is_active", value: true)
            .ilike("name", pattern: "%\(query)%")
            .order("member_count", ascending: false)
            .execute()
            .value

        return try await enrichChannelsWithJoinState(response)
    }

    // MARK: - 私有辅助方法

    private func enrichChannelsWithJoinState(_ dbChannels: [DBChannel]) async throws -> [Channel] {
        guard let userId = supabase.currentUserId else {
            return dbChannels.map { $0.toDomain(isJoined: false) }
        }

        let channelIds = dbChannels.map { $0.id }

        if channelIds.isEmpty {
            return []
        }

        // 获取用户加入的频道
        let members: [DBChannelMember] = try await supabase.database
            .from(Tables.channelMembers)
            .select("channel_id")
            .eq("user_id", value: userId)
            .in("channel_id", values: channelIds)
            .execute()
            .value

        let joinedIds = Set(members.map { $0.channelId })

        return dbChannels.map { channel in
            channel.toDomain(isJoined: joinedIds.contains(channel.id))
        }
    }

    private func mapCategoryToDB(_ category: ChannelCategory) -> String {
        switch category {
        case .creatures: return "marine_life"
        case .equipment: return "equipment"
        case .trading: return "marketplace"
        case .general: return "general"
        }
    }
}

// MARK: - 频道错误

enum ChannelError: LocalizedError {
    case unauthorized
    case notFound
    case alreadyJoined
    case notMember

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "请先登录"
        case .notFound:
            return "频道不存在"
        case .alreadyJoined:
            return "你已经加入了该频道"
        case .notMember:
            return "你还没有加入该频道"
        }
    }
}
