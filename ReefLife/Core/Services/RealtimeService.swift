//
//  RealtimeService.swift
//  ReefLife
//
//  实时服务 - 处理实时订阅功能
//

import Foundation
import Combine
import Supabase
import Realtime

// MARK: - 实时服务协议
protocol RealtimeServiceProtocol {
    func subscribeToPostComments(postId: String) -> AnyPublisher<Comment, Never>
    func subscribeToNotifications() -> AnyPublisher<AppNotification, Never>
    func subscribeToChannelOnlineCount(channelId: String) -> AnyPublisher<Int, Never>
    func unsubscribeAll()
}

// MARK: - 实时服务实现
final class RealtimeService: RealtimeServiceProtocol, ObservableObject {
    /// 单例实例
    static let shared = RealtimeService()

    private let supabase = SupabaseClientManager.shared
    private var realtimeChannels: [RealtimeChannelV2] = []
    private var cancellables = Set<AnyCancellable>()

    /// 未读通知数量
    @Published private(set) var unreadNotificationCount: Int = 0

    private init() {}

    // MARK: - 订阅帖子评论

    /// 注意：实时订阅需要 Supabase Realtime 启用
    /// 当前实现为简化版本，实际使用时需要配置 Realtime
    func subscribeToPostComments(postId: String) -> AnyPublisher<Comment, Never> {
        let subject = PassthroughSubject<Comment, Never>()

        Task {
            let channel = supabase.client.realtimeV2.channel("comments:\(postId)")

            let insertions = channel.postgresChange(
                InsertAction.self,
                table: "comments",
                filter: "post_id=eq.\(postId)"
            )

            await channel.subscribe()

            Task {
                for await insertion in insertions {
                    if let commentId = insertion.record["id"]?.stringValue {
                        if let comment = try? await self.fetchCommentDetail(id: commentId) {
                            subject.send(comment)
                        }
                    }
                }
            }

            self.realtimeChannels.append(channel)
        }

        return subject.eraseToAnyPublisher()
    }

    // MARK: - 订阅通知

    func subscribeToNotifications() -> AnyPublisher<AppNotification, Never> {
        let subject = PassthroughSubject<AppNotification, Never>()

        guard let userId = supabase.currentUserId else {
            return Empty().eraseToAnyPublisher()
        }

        Task {
            let channel = supabase.client.realtimeV2.channel("notifications:\(userId)")

            let insertions = channel.postgresChange(
                InsertAction.self,
                table: "notifications",
                filter: "user_id=eq.\(userId)"
            )

            await channel.subscribe()

            Task {
                for await insertion in insertions {
                    if let record = try? JSONEncoder().encode(insertion.record),
                       let notification = try? JSONDecoder().decode(DBNotification.self, from: record) {
                        let appNotification = notification.toDomain()
                        subject.send(appNotification)

                        await MainActor.run {
                            self.unreadNotificationCount += 1
                        }
                    }
                }
            }

            self.realtimeChannels.append(channel)
        }

        return subject.eraseToAnyPublisher()
    }

    // MARK: - 订阅频道在线人数

    func subscribeToChannelOnlineCount(channelId: String) -> AnyPublisher<Int, Never> {
        let subject = CurrentValueSubject<Int, Never>(0)

        // 简化实现：返回固定值，实际使用时需要配置 Supabase Realtime Presence
        // 由于 Supabase Swift SDK 的 Presence API 复杂性，这里简化处理
        // 完整实现需要根据具体的 SDK 版本文档进行调整

        return subject.eraseToAnyPublisher()
    }

    // MARK: - 取消所有订阅

    func unsubscribeAll() {
        for channel in realtimeChannels {
            Task {
                await channel.unsubscribe()
            }
        }
        realtimeChannels.removeAll()
    }

    // MARK: - 刷新未读通知数量

    func refreshUnreadNotificationCount() async {
        guard let userId = supabase.currentUserId else {
            await MainActor.run { self.unreadNotificationCount = 0 }
            return
        }

        do {
            let response: [DBNotification] = try await supabase.database
                .from(Tables.notifications)
                .select("id")
                .eq("user_id", value: userId)
                .eq("is_read", value: false)
                .execute()
                .value

            await MainActor.run {
                self.unreadNotificationCount = response.count
            }
        } catch {
            print("获取未读通知数量失败: \(error)")
        }
    }

    // MARK: - 标记所有通知为已读

    func markAllNotificationsRead() async throws {
        guard let userId = supabase.currentUserId else { return }

        try await supabase.database
            .rpc(RPCFunctions.markAllNotificationsRead, params: ["p_user_id": userId])
            .execute()

        await MainActor.run {
            self.unreadNotificationCount = 0
        }
    }

    // MARK: - 私有方法

    private func fetchCommentDetail(id: String) async throws -> Comment? {
        let detail: DBCommentDetail = try await supabase.database
            .from(Views.commentDetails)
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value

        return detail.toDomain()
    }
}

// MARK: - 通知服务扩展
extension RealtimeService {
    /// 获取通知列表
    func getNotifications(page: Int = 1, limit: Int = 20) async throws -> [AppNotification] {
        guard let userId = supabase.currentUserId else {
            throw AuthError.unauthorized
        }

        let response: [DBNotification] = try await supabase.database
            .from(Tables.notifications)
            .select()
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .range(from: (page - 1) * limit, to: page * limit - 1)
            .execute()
            .value

        return response.map { $0.toDomain() }
    }

    /// 标记单个通知为已读
    func markNotificationRead(id: String) async throws {
        try await supabase.database
            .from(Tables.notifications)
            .update(["is_read": true])
            .eq("id", value: id)
            .execute()

        await MainActor.run {
            if self.unreadNotificationCount > 0 {
                self.unreadNotificationCount -= 1
            }
        }
    }

    /// 删除通知
    func deleteNotification(id: String) async throws {
        try await supabase.database
            .from(Tables.notifications)
            .delete()
            .eq("id", value: id)
            .execute()
    }
}

// MARK: - 用户关注服务扩展
extension RealtimeService {
    /// 关注用户
    func followUser(userId: String) async throws {
        guard let currentUserId = supabase.currentUserId else {
            throw AuthError.unauthorized
        }

        let follow = DBUserFollow(
            id: nil,
            followerId: currentUserId,
            followingId: userId,
            createdAt: nil
        )

        try await supabase.database
            .from(Tables.userFollows)
            .insert(follow)
            .execute()

        // 创建关注通知
        try await supabase.database
            .rpc(RPCFunctions.createNotification, params: [
                "p_user_id": userId,
                "p_type": "follow",
                "p_actor_id": currentUserId,
                "p_title": "有人关注了你",
                "p_body": ""
            ])
            .execute()
    }

    /// 取消关注用户
    func unfollowUser(userId: String) async throws {
        guard let currentUserId = supabase.currentUserId else {
            throw AuthError.unauthorized
        }

        try await supabase.database
            .from(Tables.userFollows)
            .delete()
            .eq("follower_id", value: currentUserId)
            .eq("following_id", value: userId)
            .execute()
    }

    /// 检查是否关注了用户
    func isFollowing(userId: String) async throws -> Bool {
        guard let currentUserId = supabase.currentUserId else {
            return false
        }

        let response: [DBUserFollow] = try await supabase.database
            .from(Tables.userFollows)
            .select()
            .eq("follower_id", value: currentUserId)
            .eq("following_id", value: userId)
            .limit(1)
            .execute()
            .value

        return !response.isEmpty
    }

    /// 获取关注列表
    func getFollowing(userId: String, page: Int = 1, limit: Int = 20) async throws -> [User] {
        let follows: [DBUserFollow] = try await supabase.database
            .from(Tables.userFollows)
            .select()
            .eq("follower_id", value: userId)
            .order("created_at", ascending: false)
            .range(from: (page - 1) * limit, to: page * limit - 1)
            .execute()
            .value

        let userIds = follows.map { $0.followingId }

        if userIds.isEmpty {
            return []
        }

        let users: [DBUser] = try await supabase.database
            .from(Tables.users)
            .select()
            .in("id", values: userIds)
            .execute()
            .value

        return users.map { $0.toDomain() }
    }

    /// 获取粉丝列表
    func getFollowers(userId: String, page: Int = 1, limit: Int = 20) async throws -> [User] {
        let follows: [DBUserFollow] = try await supabase.database
            .from(Tables.userFollows)
            .select()
            .eq("following_id", value: userId)
            .order("created_at", ascending: false)
            .range(from: (page - 1) * limit, to: page * limit - 1)
            .execute()
            .value

        let userIds = follows.map { $0.followerId }

        if userIds.isEmpty {
            return []
        }

        let users: [DBUser] = try await supabase.database
            .from(Tables.users)
            .select()
            .in("id", values: userIds)
            .execute()
            .value

        return users.map { $0.toDomain() }
    }
}
